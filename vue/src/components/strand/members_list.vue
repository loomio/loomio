<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {map, debounce, without} from 'lodash'

export default
  props:
    discussion: Object

  data: ->
    readers: []
    query: ''
    searchResults: []
    recipients: []
    emailAddresses: null

  mounted: ->
    @fetchMemberships = debounce ->
      Records.memberships.fetchByNameFragment(@query, @discussion.group().key, 20) unless @emailAddresses

    Records.discussionReaders.fetch
      path: ''
      params:
        discussion_id: @discussion.id

    @watchRecords
      collections: ['memberships']
      query: (records) => @updateSearchResults()

    @watchRecords
      collections: ['discussionReaders']
      query: (records) => @updateReaders()

  watch:
    query: (q) ->
      @search(q)
      @updateReaders()
      @updateSearchResults()

  methods:
    search: ->
      return unless @query && @query.length > 2
      @emailAddresses = @query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g)
      @fetchMemberships() unless @emailAddresses

    openInviteModal: ->
      EventBus.$emit 'openModal',
        component: 'StrandMembersList',
        props: { discussion: discussion }

    remove: (item) ->
      @discussion.recipientIds = without(@discussion.recipientIds, item.id)

    updateReaders: ->
      chain = Records.discussionReaders.collection.chain().
                find(discussionId: @discussion.id)

      if @query
        users = Records.users.collection.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]
        chain = chain.find(userId: {$in: map(users, 'id')})

      @readers = chain.data()

    updateSearchResults: ->
      if @emailAddresses
        @searchResults = @recipients.concat @emailAddresses.map (e) ->
          id: e
          isEmail: true
          name: e
      else
        memberIds = without(@discussion.group().memberIds(), Session.user().id)
        chain = Records.users.collection.chain().find(id: {$in: memberIds})
        if @query
          chain = chain.find(
            $or: [
              {name: {'$regex': ["^#{@query}", "i"]}},
              {username: {'$regex': ["^#{@query}", "i"]}},
              {name: {'$regex': [" #{@query}", "i"]}}
            ]
          )
        @searchResults = @recipients.concat chain.simplesort('name').data()

</script>

<template lang="pug">
.strand-members-list
  discussion-privacy-badge.pa-4(:discussion="discussion")
  v-autocomplete.px-4(multiple chips
    return-object
    auto-select-first
    hide-no-data
    hide-selected
    v-model='recipients'
    @change="query= ''"
    :search-input.sync="query"
    item-text='name'
    :label="$t('discussion_form.invite')"
    :items='searchResults')
    template(v-slot:selection='data')
      v-chip.chip--select-multi(:value='data.selected' close @click:close='remove(data.item)')
        v-icon.mr-1(v-if="data.item.isEmail" small) mdi-email-outline
        user-avatar.mr-1(v-else :user="data.item" size="small" no-link)
        span {{ data.item.name }}
    template(v-slot:item='data')
      v-list-item-avatar
        v-icon(v-if="data.item.isEmail") mdi-email-outline
        user-avatar(v-else :user="data.item" size="small" no-link)
      v-list-item-content.announcement-chip__content
        v-list-item-title(v-html='data.item.name')
  v-list
    v-subheader Participants
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      v-list-item-avatar
        user-avatar(:user="reader.user()")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{reader.user().nameWithTitle(discussion.group())}}
          v-chip(v-if="reader.admin" outlined x-small label v-t="'members_panel.admin'")
        //- v-list-item-subtitle Admin
      v-list-item-icon
        v-icon mdi-horizontal-dots
</template>

<style lang="sass">
</style>
