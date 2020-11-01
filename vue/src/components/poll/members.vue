<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import StanceService from '@/shared/services/stance_service'
import {audiencesFor, audienceSize, audienceValuesFor} from '@/shared/helpers/announcement.coffee'
import {map, debounce, without, filter, uniq, uniqBy, some, find} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    poll: Object

  data: ->
    stances: []
    membershipsByUserId: {}
    stanceUserIds: []
    reset: false
    saving: false
    initialRecipients: []
    actionNames: []
    service: StanceService
    query: ''

  mounted: ->
    @actionNames = ['makeAdmin', 'removeAdmin', 'revoke'] # 'resend'

    @fetchStances()
    @updateStances()

    @watchRecords
      collections: ['stances', 'memberships']
      query: (records) => @updateStances()

  computed:
    someRecipients: ->
      @poll.recipientAudience ||
      @poll.recipientUserIds.length ||
      @poll.recipientEmails.length

  methods:
    isAdmin: (stance) ->
      stance.admin || @membershipsByUserId[stance.participantId] && @membershipsByUserId[stance.participantId].admin

    isGuest: (stance) ->
      !@membershipsByUserId[stance.participantId]

    inviteRecipients: ->
      @saving = true
      Records.announcements.remote.post '',
        poll_id: @poll.id
        recipient_audience: @poll.recipientAudience
        recipient_user_ids: @poll.recipientUserIds
        recipient_emails: @poll.recipientEmails
      .then (data) =>
        console.log data
        count = data.stances.length
        Flash.success('announcement.flash.success', { count: count })
        @reset = !@reset
      .finally =>
        @saving = false

    newQuery: (query) ->
      @query = query
      @updateStances()
      @fetchStances()

    fetchStances: debounce ->
      Records.stances.fetch
        params:
          exclude_types: 'poll group'
          poll_id: @poll.id
          query: @query
      .then (records) =>
        userIds = map records['users'], 'id'
        Records.memberships.fetch
          params:
            exclude_types: 'group user'
            group_id: @poll.groupId
            user_ids: userIds.join(' ')
    , 300

    updateStances: ->
      chain = Records.stances.collection.chain().
              find(pollId: @poll.id).
              find(revokedAt: null)

      if @query
        users = Records.users.collection.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {email: {'$regex': ["#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]
        chain = chain.find(participantId: {$in: map(users, 'id')})

      @stances = chain.data()
      @stanceUserIds = map(Records.stances.collection.find(pollId: @poll.id), 'participantId')

      @membershipsByUserId = {}
      Records.memberships.collection.find(userId: {$in: @stanceUserIds}).forEach (m) =>
        @membershipsByUserId[m.userId] = m

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
      :excludedAudiences="['voters', 'undecide', 'non_voters', 'participants']"
      :excludedUserIds="stanceUserIds"
      :initialRecipients="initialRecipients"
      @new-query="newQuery")
    .d-flex
      v-spacer
      v-btn.poll-members-list__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="inviteRecipients" )
        span(v-t="'common.action.invite'")
  v-list
    v-subheader
      span(v-t="{path: 'membership_card.poll_members', args: {pollType: poll.translatedPollType()}}")
      space
      span ({{poll.stancesCount}})
    v-list-item(v-for="stance in stances" :user="stance.participant()" :key="stance.id")
      v-list-item-avatar
        user-avatar(:user="stance.participant()" :size="24")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{stance.participant().nameWithTitle(poll.group())}}
          v-chip.mr-1(v-if="isGuest(stance)" outlined x-small label v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')")
          v-chip.mr-1(v-if="isAdmin(stance)" outlined x-small label v-t="'members_panel.admin'")

      v-list-item-action
        v-menu(offset-y)
          template(v-slot:activator="{on, attrs}")
            v-btn.membership-dropdown__button(icon v-on="on" v-bind="attrs")
              v-icon mdi-dots-vertical
          v-list
            v-list-item(v-for="action in actionNames" v-if="service[action].canPerform(stance)" @click="service[action].perform(stance)" :key="action")
              v-list-item-title(v-t="{ path: service[action].name, args: { pollType: poll.translatedPollType() } }")

    v-list-item(v-if="query && stances.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")
</template>
