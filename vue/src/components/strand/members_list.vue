<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import DiscussionReaderService from '@/shared/services/discussion_reader_service'
import {map, debounce, without, filter, uniq, uniqBy, some, pick} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    discussion: Object

  data: ->
    readers: []
    query: ''
    searchResults: []
    recipients: []
    membershipsByUserId: {}
    readerUserIds: []
    reset: false
    saving: false
    actionNames: []
    service: DiscussionReaderService

  mounted: ->
    @actionNames = ['makeAdmin', 'removeAdmin', 'revoke'] # 'resend'

    @watchRecords
      collections: ['discussionReaders', 'memberships']
      query: (records) => @updateReaders()

  computed:
    model: -> @discussion

    excludedUserIds: ->
      @readerUserIds.concat(Session.user().id)

  methods:
    isGroupAdmin: (reader) ->
      @membershipsByUserId[reader.userId] && @membershipsByUserId[reader.userId].admin

    isGuest: (reader) ->
      !@membershipsByUserId[reader.userId]

    inviteRecipients: ->
      count = @recipients.length
      @saving = true
      params = Object.assign
        discussion_id: @discussion.id
      ,
        recipient_audience: @discussion.recipientAudience
        recipient_user_ids: @discussion.recipientUserIds
        recipient_emails: @discussion.recipientEmails
      Records.announcements.remote.post '', params
      .then =>
        @reset = !@reset
        Flash.success('announcement.flash.success', { count: count })
      .finally =>
        @saving = false

    newQuery: (query) ->
      @query = query
      @updateReaders()
      @fetchReaders()

    newRecipients: (recipients) -> @recipients = recipients

    fetchReaders: debounce ->
      Records.discussionReaders.fetch
        params:
          exclude_types: 'discussion'
          query: @query
          discussion_id: @discussion.id
      .then (records) =>
        userIds = map records['users'], 'id'
        Records.memberships.fetch
          params:
            exclude_types: 'group inviter'
            group_id: @discussion.groupId
            user_xids: userIds.join('x')
      .finally => @updateReaders()
    , 300

    updateReaders: ->
      chain = Records.discussionReaders.collection.chain().
              find(discussionId: @discussion.id).
              find(revokedAt: null)

      if @query
        users = Records.users.collection.find
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {email: {'$regex': ["#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]
        chain = chain.find(userId: {$in: map(users, 'id')})

      chain = chain.simplesort('id', true)
      @readers = chain.data()
      @readerUserIds = map(Records.discussionReaders.collection.find(discussionId: @discussion.id), 'userId')

      @membershipsByUserId = {}
      Records.memberships.collection.find(userId: {$in: @readerUserIds}).forEach (m) =>
        @membershipsByUserId[m.userId] = m

</script>

<template lang="pug">
.strand-members-list
  .px-4.pt-4
    .d-flex.justify-space-between
      h1.headline(v-t="'announcement.form.discussion_announced.title'")
      dismiss-modal-button

    recipients-autocomplete(
      :label="$t('announcement.form.discussion_announced.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :model="discussion"
      :excluded-user-ids="excludedUserIds"
      :excluded-audiences="['discussion_group']"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")
    .d-flex
      v-spacer
      v-btn.strand-members-list__submit(
        color="primary"
        :disabled="!recipients.length"
        :loading="saving"
        @click="inviteRecipients"
        v-t="'common.action.invite'")

  v-list(two-line)
    v-subheader
      span(v-t="'membership_card.discussion_members'")
      space
      span ({{discussion.membersCount}})
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      v-list-item-avatar
        user-avatar(:user="reader.user()" :size="24")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{reader.user().nameWithTitle(discussion.group())}}
          v-chip.mr-1(v-if="discussion.groupId && isGuest(reader)" outlined x-small label v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')")
          v-chip.mr-1(v-if="reader.admin" outlined x-small label v-t="'announcement.members_list.thread_admin'")
          v-chip.mr-1(v-if="isGroupAdmin(reader)" outlined x-small label v-t="'announcement.members_list.group_admin'")
        v-list-item-subtitle
          span(v-if="reader.lastReadAt" v-t="{ path: 'announcement.members_list.last_read_at', args: { time: approximateDate(reader.lastReadAt) } }")
          span(v-else v-t="'announcement.members_list.has_not_read_thread'")
          //- time-ago(:date="reader.lastReadAt")
      v-list-item-action
        v-menu(offset-y)
          template(v-slot:activator="{on, attrs}")
            v-btn.membership-dropdown__button(icon v-on="on" v-bind="attrs")
              v-icon mdi-dots-vertical
          v-list
            v-list-item(v-for="action in actionNames" v-if="service[action].canPerform(reader)" @click="service[action].perform(reader)" :key="action")
              v-list-item-title(v-t="service[action].name")
    v-list-item(v-if="query && readers.length == 0")
      v-list-item-title(v-t="{ path: 'discussions_panel.no_results_found', args: { search: query }}")


</template>
