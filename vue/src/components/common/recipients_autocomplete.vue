<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {map, debounce, without, filter, uniq, uniqBy, find} from 'lodash'
import RecipientsNotificationsCount from '@/components/common/recipients_notifications_count'
import AbilityService from '@/shared/services/ability_service'

export default
  components: {
    RecipientsNotificationsCount
  }

  props:
    autofocus: Boolean
    label: String
    placeholder: String
    hint: String
    reset: Boolean
    model: Object
    excludedAudiences:
      type: Array
      default: -> []
    excludedUserIds:
      type: Array
      default: -> [Session.user().id]
    initialRecipients:
      type: Array
      default: -> []

  data: ->
    query: ''
    suggestions: []
    recipients: []
    loading: false

  mounted: ->
    @recipients = @initialRecipients
    @fetchAndUpdateSuggestions()

  watch:
    'model.groupId': (groupId) ->
      @newRecipients(@initialRecipients)
      @fetchAndUpdateSuggestions()

    reset: ->
      @query = ''
      @recipients = @initialRecipients
      @fetchAndUpdateSuggestions()

    recipients: (val) ->
      @newRecipients(val)
      @$emit('new-recipients', val)
      @updateSuggestions()

    query: (q) ->
      @$emit('new-query', q)
      @fetchAndUpdateSuggestions()

  methods:
    fetchAndUpdateSuggestions: ->
      @fetchMemberships()
      @updateSuggestions()

    fetchMemberships: debounce ->
      return unless @query

      emails = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])
      return if emails.length

      @loading = true

      Records.memberships.fetch
        params:
          exclude_types: 'group inviter'
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
      @model.recipientAudience = (find(val, (o) -> o.type == 'audience') || {}).id
      @model.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @model.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

    findUsers: ->
      # return [] unless @query
      chain = Records.users.collection.chain()

      if @model.group().id
        chain = chain.find(id: {$in: @model.group().parentAndSelfMemberIds()})

      chain = chain.find(emailVerified: true)
      chain = chain.find(id: {$nin: @excludedUserIds})

      chain = chain.find
        $or: [
          {name: {'$regex': ["^#{@query}", "i"]}}
          {username: {'$regex': ["^#{@query}", "i"]}}
          {name: {'$regex': [" #{@query}", "i"]}}
        ]

      chain.data()

    notificationsCount: ->
      sum(@recipients.map((r) => r.size || 1))

    remove: (item) ->
      @recipients = filter @recipients, (r) ->
        !(r.id == item.id && r.type == item.type)

    emailToRecipient: (email) ->
      id: email
      type: 'email'
      icon: 'mdi-email-outline'
      name: email

    updateSuggestions: ->
      if @query
        emails = uniq(@query.match(/[^\s:,;'"`<>]+?@[^\s:,;'"`<>]+\.[^\s:,;'"`<>]+/g) || [])

        # catch paste of multiple email addresses, or failure to press enter after an email address
        if emails.length > 1 or (emails.length == 1 && [',', ' '].includes(@query.slice(-1)))
          objs = uniqBy @recipients.concat(emails.map(@emailToRecipient)), 'id'
          @recipients = objs
          @suggestions = objs
          @query = ''
          return
        else if emails.length == 1
          @suggestions = @recipients.concat emails.map(@emailToRecipient)
          return

      members = @findUsers().map (u) ->
        id: u.id
        type: 'user'
        name: u.nameOrEmail()
        user: u

      audiences = @audiences.map (a) ->
        id: a.id
        type: 'audience'
        icon: 'mdi-account-group'
        name: a.name
        size: a.size

      @suggestions = @recipients.concat(audiences).concat(members)

  computed:
    modelName: -> @model.constructor.singular

    audiences: ->
      ret = []
      canAnnounce = !!(@model.group().adminsInclude(Session.user()) || @model.group().membersCanAnnounce)
      if @recipients.length == 0
        if @model.groupId && canAnnounce
          ret.push
            id: 'group'
            name: @$t('announcement.audiences.group', name: @model.group().name)
            size: @model.group().acceptedMembershipsCount
            icon: 'mdi-account-group'

        if @model.discussion && (@model.discussion() || {}).id && AbilityService.canAnnounceTo(@model.discussion())
          ret.push
            id: 'discussion_group'
            name: @$t('announcement.audiences.discussion_group')
            size: @model.discussion().membersCount
            icon: 'mdi-forum'

        if @model.poll && @model.poll()
          if @model.poll().votersCount > 1
            ret.push
              id: 'voters'
              name: @$t('announcement.audiences.voters', pollType: @model.poll().translatedPollType())
              size: @model.poll().votersCount
              icon: 'mdi-forum'

          if @model.poll().decidedVotersCount > 0
            ret.push
              id: 'decided_voters'
              name: @$t('announcement.audiences.decided_voters')
              size: @model.poll().decidedVotersCount
              icon: 'mdi-forum'

          if @model.poll().decidedVotersCount > 0 && @model.poll().undecidedVotersCount > 0
            ret.push
              id: 'undecided_voters'
              name: @$t('announcement.audiences.undecided_voters')
              size: @model.poll().undecidedVotersCount
              icon: 'mdi-forum'

        # non voters
        # also subgroups

      ret.filter (a) =>
        !@excludedAudiences.includes(a.id) &&
        ((@query && a.name.match(new RegExp(@query, 'i'))) || true)

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
    :hint="hint"
    :placeholder="placeholder"
    :items='suggestions'
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
  //- recipients-notifications-count(:model="model")
</template>
