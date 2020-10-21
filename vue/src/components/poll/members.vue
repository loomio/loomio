<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import StanceService from '@/shared/services/stance_service'
import {audiencesFor, audienceSize, audienceValuesFor} from '@/shared/helpers/announcement.coffee'
import {map, debounce, without, filter, uniq, uniqBy, some} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    poll: Object

  data: ->
    stances: []
    query: ''
    searchResults: []
    recipients: []
    excludedUserIds: []
    membershipsByUserId: {}
    stanceUserIds: []
    reset: false
    saving: false
    initialRecipients: []
    fetchingAudience: false
    actionNames: []
    service: StanceService

  mounted: ->
    @actionNames = ['makeAdmin', 'removeAdmin', 'revoke'] # 'resend'
    # TODO add query support to this fetch for when there are many readers
    Records.stances.fetch
      params:
        poll_id: @poll.id
        exclude_types: 'poll'
    .then (records) =>
      userIds = map records['users'], 'id'
      Records.memberships.fetch
        path: 'autocomplete'
        params:
          group_id: @poll.groupId
          user_ids: userIds.join(' ')

    @watchRecords
      collections: ['stances', 'memberships']
      query: (records) => @updateStances()

  watch:
    query: -> @updateStances()

  computed:
    audiences: ->
      ret = []
      if @recipients.length == 0
        if @poll.stancesCount < @poll.group().acceptedMembershipsCount
          ret.push 'group'
        if @poll.discussionId && @poll.stancesCount < @poll.discussion().membersCount
          ret.push 'discussion_group'
      ret

  methods:
    isAdmin: (stance) ->
      stance.admin || @membershipsByUserId[stance.participantId] && @membershipsByUserId[stance.participantId].admin

    isGuest: (stance) ->
      !@membershipsByUserId[stance.participantId]

    inviteRecipients: ->
      count = @recipients.length
      @saving = true
      Records.announcements.remote.post '',
        poll_id: @poll.id
        recipients:
          user_ids: map filter(@recipients, (r) -> r.type == 'user'), 'id'
          emails: map filter(@recipients, (r) -> r.type == 'email'), 'id'
      .then =>
        @reset = !@reset
      .finally =>
        Flash.success('announcement.flash.success', { count: count })
        @saving = false

    newQuery: (query) -> @query = query
    newRecipients: (recipients) -> @recipients = recipients

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
      @excludedUserIds = @stanceUserIds.concat(Session.user().id)

      @membershipsByUserId = {}
      Records.memberships.collection.find(userId: {$in: @stanceUserIds}).forEach (m) =>
        @membershipsByUserId[m.userId] = m

    audienceSize: (audience) -> audienceSize(@poll, audience)

    fetchAudience: (kind) ->
      @fetchingAudience = true
      Records.announcements.fetch
        path: 'audience'
        params:
          poll_id: @poll.id
          kind: kind
          return_users: 1
          without_exising: 1
      .then (users) =>
        @initialRecipients = Records.users.find(map(users, 'id')).map (user) =>
          id: user.id
          type: 'user'
          name: user.name
          user: user
        @reset = !@reset
      .finally => @fetchingAudience = false
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
      :group="poll.group()"
      :excluded-user-ids="excludedUserIds"
      :reset="reset"
      :initialRecipients="initialRecipients"
      @new-query="newQuery"
      @new-recipients="newRecipients")
    div.caption(v-if="audiences.length")
      span(v-if="fetchingAudience" v-t="'common.action.loading'")
      span(v-else)
        span(v-t="'announcement.quick_add'")
        space
        span(v-for='(audience, index) in audiences' :key='index')
          a.announcement-form__audience(@click='fetchAudience(audience)')
            span(v-t="{ path: 'announcement.audiences.' + audience, args: {name: poll.group().name} }")
          span(v-if="index < audiences.length - 1")
            | ,
            space
    .d-flex
      v-spacer
      v-btn.poll-members-list__submit(color="primary" :disabled="!recipients.length && saving" @click="inviteRecipients" @loading="saving")
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
