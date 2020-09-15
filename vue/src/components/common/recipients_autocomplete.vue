<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {map, debounce, without, filter, uniq, uniqBy} from 'lodash'

export default
  # emits: query, recipients
  props:
    showGroups: Boolean
    group: Object
    excludedUserIds: Array
    label: String
    placeholder: String

  data: ->
    query: ''
    searchResults: []
    recipients: []
    emailAddresses: []
    loading: false

  mounted: ->
    @fetchMemberships = debounce ->
      @loading = true
      Records.memberships.fetch
        path: 'autocomplete'
        params:
          exclude_types: 'group'
          q: @query
          group_id: @group.id
          per: 10
      .finally =>
        @loading = false
    , 300

    @fetchMemberships()

    @watchRecords
      collections: ['memberships']
      query: (records) => @updateSearchResults()

  watch:
    recipients: (val) ->
      @$emit('new-recipients', val)
    query: (q) ->
      @$emit('new-query', q)
      @search(q)
      @updateSearchResults()

  methods:
    search: ->
      return unless @query

      @emailAddresses = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])

      @fetchMemberships() if @emailAddresses.length == 0

      # catch paste of multiple email addresses, or failure to press enter after an email address
      if @emailAddresses.length > 1 or (@emailAddresses.length == 1 && [',', ' '].includes(@query.slice(-1)))
        objs = uniqBy @recipients.concat(@emailAddresses.map((e) -> {id: e, isEmail: true, name: e})), 'id'
        @recipients = objs
        @searchResults = objs
        @query = ''
        @emailAddresses = []
        return

    remove: (item) ->
      @recipients = filter @recipients, (r) ->
        r.id != item.id && r.type == item.type

    updateSearchResults: ->
      if @emailAddresses.length
        @searchResults = @recipients.concat @emailAddresses.map (e) ->
          id: e
          type: 'email'
          name: e
        return

      memberChain = Records.users.collection.chain().
                    find(id: {$in: @group.memberIds()}).
                    find(id: {$nin: @excludedUserIds})
      if @query
        memberChain = memberChain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]

      members = memberChain.data().map (u) ->
        id: u.id
        type: 'user'
        name: u.name
        user: u

      groups = []
      if @showGroups
        groupChain = Records.groups.collection.chain().
                     find(parentId: @group.id).
                     simplesort('openDiscussionsCount', true)

        if @query
          groupChain = groupChain.find(name: {'$regex': [@query, 'i']})

        groups = groupChain.data().map (g) ->
          id: g.id
          type: 'group'
          name: g.name

      @searchResults = @recipients.concat(groups).concat(members)


</script>

<template lang="pug">
v-autocomplete.px-4(
  multiple
  chips
  return-object
  auto-select-first
  hide-no-data
  hide-selected
  v-model='recipients'
  @change="query= ''"
  :search-input.sync="query"
  item-text='name'
  :loading="loading"
  :label="label"
  :placeholder="placeholder"
  :items='searchResults')
  template(v-slot:selection='data')
    v-chip.chip--select-multi(:value='data.selected' close @click:close='remove(data.item)')
      v-icon.mr-1(v-if="data.item.type == 'email'" small) mdi-email-outline
      v-icon.mr-1(v-if="data.item.type == 'group'" small) mdi-account-group
      user-avatar.mr-1(v-if="data.item.type == 'user'" :user="data.item.user" size="small" no-link)
      span {{ data.item.name }}
  template(v-slot:item='data')
    v-list-item-avatar
      v-icon(v-if="data.item.type == 'email'" small) mdi-email-outline
      v-icon.mr-1(v-if="data.item.type == 'group'" small) mdi-account-group
      user-avatar(v-if="data.item.type == 'user'" :user="data.item.user" size="small" no-link)
    v-list-item-content.announcement-chip__content
      v-list-item-title(v-html='data.item.name')
</template>
