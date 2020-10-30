<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {map, debounce, without, filter, uniq, uniqBy, find} from 'lodash'
import RecipientsNotificationsCount from '@/components/common/recipients_notifications_count'

export default
  components: {
    RecipientsNotificationsCount
  }

  props:
    autofocus: Boolean
    label: String
    placeholder: String
    reset: Boolean
    model: Object
    initialRecipients:
      type: Array
      default: -> []

  data: ->
    query: ''
    searchResults: []
    recipients: @initialRecipients
    emailAddresses: []
    loading: false
    users: []
    groups: []

  created: ->

  mounted: ->
    @updateSearchResults()
    @fetchMemberships()

  watch:
    'model.groupId': (groupId) ->
      @fetchMemberships()
      @updateSuggestions()
      @newRecipients(@initialRecipients)

    reset: ->
      @query = ''
      @recipients = @initialRecipients
      @emailAddresses = []
      @updateSearchResults()

    groups: ->
      @updateSearchResults()

    audiences: ->
      @updateSearchResults()

    users: ->
      @updateSearchResults()

    recipients: (val) ->
      @newRecipients(val)
      @$emit('new-recipients', val)

    query: (q) ->
      @$emit('new-query', q)
      @findEmailAddresses(q)
      @updateSearchResults()
      @updateSuggestions()
      @fetchMemberships()

  methods:
    fetchMemberships: debounce ->
      if @query
        emails = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])
        return if emails.length

      @loading = true

      Records.memberships.fetch
        params:
          exclude_types: 'group'
          q: @query
          subgroups: 'all'
          per: 20
          group_id: @model.group().parentOrSelf().id
      .then =>
        @updateSuggestions()
      .finally =>
        @loading = false

    , 300

    newRecipients: (val) ->
      console.log "new recipieitns", (find(val, (o) -> o.type == 'audience') || {}).id
      @model.recipientAudience = (find(val, (o) -> o.type == 'audience') || {}).id
      @model.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @model.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

    updateSuggestions: ->
      @users = @findUsers()

    excludedUserIds: ->
      [Session.user().id]

    findUsers: ->
      chain = Records.users.collection.chain()

      if @model.groupId
        chain = chain.find(id: {$in: @model.group().parentAndSelfMemberIds()})

      chain = chain.find(id: {$nin: @excludedUserIds()})

      if @query
        chain = chain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}}
            {username: {'$regex': ["^#{@query}", "i"]}}
            {name: {'$regex': [" #{@query}", "i"]}}
          ]

      chain.data()


    newQuery: (query) ->
      @query = query

    notificationsCount: ->
      sum(@recipients.map((r) => r.size || 1))

    findEmailAddresses: ->
      return unless @query

      @emailAddresses = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])

      # catch paste of multiple email addresses, or failure to press enter after an email address
      if @emailAddresses.length > 1 or (@emailAddresses.length == 1 && [',', ' '].includes(@query.slice(-1)))
        objs = uniqBy @recipients.concat(@emailAddresses.map((e) -> {id: e, type: 'email', name: e})), 'id'
        @recipients = objs
        @searchResults = objs
        @query = ''
        @emailAddresses = []
        return

    remove: (item) ->
      @recipients = filter @recipients, (r) ->
        !(r.id == item.id && r.type == item.type)

    updateSearchResults: ->
      if @emailAddresses.length
        @searchResults = @recipients.concat @emailAddresses.map (e) ->
          id: e
          type: 'email'
          icon: 'mdi-email-outline'
          name: e
        return

      members = @users.map (u) ->
        id: u.id
        type: 'user'
        name: u.name
        user: u

      groups = @groups.map (g) ->
        id: g.id
        type: 'group'
        name: g.name
        icon: 'mdi-account-group'
        group: g

      audiences = @audiences.map (a) ->
        id: a.id
        type: 'audience'
        icon: 'mdi-account-group'
        name: a.name
        size: a.size

      @searchResults = @recipients.concat(audiences).concat(groups).concat(members)

  computed:
    modelName: -> @model.constructor.singular

    audiences: ->
      ret = []
      canAnnounce = !!(@model.group().adminsInclude(Session.user()) || @model.group().membersCanAnnounce)
      if @recipients.length == 0
        if @model.groupId && canAnnounce
          ret.push
            id: 'group'
            name: @model.group().name
            size: @model.group().acceptedMembershipsCount
            icon: 'mdi-account-group'
        if @model.discussion() && @model.discussion().id && @model.discussion().membersCount > 1
          ret.push
            id: 'discussion_group'
            name: @$t('announcement.audiences.discussion_group')
            size: @model.discussion().membersCount
            icon: 'mdi-forum'

        if @model.poll
          if @model.poll().stancesCount > 1
            ret.push
              id: 'voters'
              name: @$t('announcement.audiences.voters')
              size: @model.poll().stancesCount
              icon: 'mdi-forum'

          if @model.poll().participantsCount > 0
            ret.push
              id: 'participants'
              name: @$t('announcement.audiences.participants')
              size: @model.poll().participantsCount
              icon: 'mdi-forum'

          if @model.poll().undecidedCount > 0
            ret.push
              id: 'undecided'
              name: @$t('announcement.audiences.undecided')
              size: @model.poll().undecidedCount
              icon: 'mdi-forum'

        # voters
        # non voters
        # partiicpants
        # undecided

        # also subgroups

      ret.filter (a) =>
        (@query && a.name.match(new RegExp(@query, 'i'))) || true
</script>

<template lang="pug">
div
  //- chips attribute is messing with e2es; no behaviour change noticed
  v-autocomplete.announcement-form__input(
    multiple
    return-object
    auto-select-first
    hide-no-data
    hide-selected
    v-model='recipients'
    @change="query = null"
    :search-input.sync="query"
    item-text='name'
    :loading="loading"
    :label="label"
    :placeholder="placeholder"
    :items='searchResults'
    )
    template(v-slot:selection='data')
      v-chip.chip--select-multi(:value='data.selected' close @click:close='remove(data.item)')
        span
          user-avatar.mr-1(v-if="data.item.type == 'user'" :user="data.item.user" size="small" no-link)
          v-icon.mr-1(v-else small) {{data.item.icon}}
        span {{ data.item.name }}
    template(v-slot:item='data')
      v-list-item-avatar
        user-avatar(v-if="data.item.type == 'user'" :user="data.item.user" size="small" no-link)
        v-icon.mr-1(v-else small) {{data.item.icon}}
      v-list-item-content.announcement-chip__content
        v-list-item-title {{data.item.name}}
  //- recipients-notifications-count(:recipients="recipients")
</template>
