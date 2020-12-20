<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import StanceService from '@/shared/services/stance_service'
import {map, debounce, without, filter, uniq, uniqBy, some, find, compact} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    poll: Object

  data: ->
    users: []
    userIds: []
    isMember: {}
    isMemberAdmin: {}
    isStanceAdmin: {}
    reset: false
    saving: false
    loading: false
    initialRecipients: []
    actionNames: []
    service: StanceService
    query: ''

  mounted: ->
    @actionNames = ['makeAdmin', 'removeAdmin', 'revoke'] # 'resend'

    @fetchStances()
    @updateStances()

    @watchRecords
      collections: ['stances', 'memberships', 'users']
      query: (records) => @updateStances()

  computed:
    someRecipients: ->
      @poll.recipientAudience ||
      @poll.recipientUserIds.length ||
      @poll.recipientEmails.length

  methods:
    canPerform: (action, poll, user) ->
      switch action
        when 'makeAdmin'
          poll.adminsInclude(Session.user()) && !@isStanceAdmin[user.id] && !@isMemberAdmin[user.id]
        when 'removeAdmin'
          poll.adminsInclude(Session.user()) && @isStanceAdmin[user.id]
        when 'revoke'
          poll.adminsInclude(Session.user())

    reset: ->

    perform: (action, poll, user) ->
      @userIds = []
      @isMember = {}
      @isMemberAdmin= {}
      @isStanceAdmin= {}
      @service[action].perform(poll, user).then =>
        @fetchStances()

    inviteRecipients: ->
      @saving = true
      Records.announcements.remote.post '',
        poll_id: @poll.id
        recipient_audience: @poll.recipientAudience
        recipient_user_ids: @poll.recipientUserIds
        recipient_emails: @poll.recipientEmails
      .then (data) =>
        count = data.stances.length
        Flash.success('announcement.flash.success', { count: count })
        @reset = !@reset
      .finally =>
        @saving = false

    toHash: (a) ->
      h = {}
      a.forEach (i) -> h[i] = true
      h

    newQuery: (query) ->
      @query = query
      @updateStances()
      @fetchStances()

    fetchStances: debounce ->
      @loading = true
      Records.fetch
        path: 'stances/users'
        params:
          exclude_types: 'poll group'
          poll_id: @poll.id
          query: @query
      .then (data) =>
        @isMember = @toHash(data['meta']['member_ids'])
        @isMemberAdmin = @toHash(data['meta']['member_admin_ids'])
        @isStanceAdmin = @toHash(data['meta']['stance_admin_ids'])
        @userIds = uniq compact @userIds.concat(map data['users'], 'id')
        @updateStances()
      .finally =>
        @loading = false
    , 300

    updateStances: ->
      chain = Records.users.collection.chain()
      chain = chain.find(id: {$in: @userIds})

      if @query
        chain = chain.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {email: {'$regex': ["#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]

      @users = chain.data()
</script>

<template lang="pug">
.poll-members-list
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.headline(v-t="'announcement.form.poll_announced.title'")
      dismiss-modal-button
    recipients-autocomplete(
      :label="$t('announcement.form.poll_announced.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedAudiences="['voters', 'undecided_voters', 'non_voters', 'decided_voters']"
      :excludedUserIds="userIds"
      :initialRecipients="initialRecipients"
      @new-query="newQuery")
    .d-flex
      v-spacer
      v-btn.poll-members-list__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients" )
        span(v-t="'common.action.invite'")
  v-list
    v-subheader
      span(v-t="'membership_card.voters'")
      space
      span ({{users.length}} / {{poll.votersCount}})
    v-list-item(v-for="user in users" :key="user.id")
      v-list-item-avatar
        user-avatar(:user="user" :size="24")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{user.nameWithTitle(poll.group())}}
          v-chip.mr-1(v-if="!isMember[user.id]" outlined x-small label v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')")
          v-chip.mr-1(v-if="isMemberAdmin[user.id] || isStanceAdmin[user.id]" outlined x-small label v-t="'members_panel.admin'")

      v-list-item-action
        v-menu(offset-y)
          template(v-slot:activator="{on, attrs}")
            v-btn.membership-dropdown__button(icon v-on="on" v-bind="attrs")
              v-icon mdi-dots-vertical
          v-list
            v-list-item(v-for="action in actionNames" v-if="canPerform(action, poll, user)" @click="perform(action, poll, user)" :key="action")
              v-list-item-title(v-t="{ path: service[action].name, args: { pollType: poll.translatedPollType() } }")

    v-list-item(v-if="query && users.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")
</template>
