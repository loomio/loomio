<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
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

  mounted: ->
    # TODO add query support to this fetch for when there are many readers
    Records.stances.fetch
      params:
        poll_id: @poll.id
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
        if @poll.stancesCount < @poll.group().activeMembershipsCount
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
      @saving = true
      Records.announcements.remote.post '',
        poll_id: @poll.id
        recipients:
          user_ids: map filter(@recipients, (r) -> r.type == 'user'), 'id'
          emails: map filter(@recipients, (r) -> r.type == 'email'), 'id'
      .then =>
        @reset = !@reset
      .finally =>
        @saving = false

    newQuery: (query) -> @query = query
    newRecipients: (recipients) -> @recipients = recipients

    updateStances: ->
      chain = Records.stances.collection.chain().
              find(pollId: @poll.id)

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
      v-btn(color="primary" :disabled="!recipients.length" @click="inviteRecipients" @loading="saving" v-t="'common.action.invite'")
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
          v-chip(v-if="isGuest(stance)" outlined x-small label v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')")
          v-chip(v-if="isAdmin(stance)" outlined x-small label v-t="'members_panel.admin'")
</template>
