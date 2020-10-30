<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import DiscussionReaderService from '@/shared/services/discussion_reader_service'
import {map, debounce, without, filter, uniq, uniqBy, some} from 'lodash'

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

    @fetchMemberships()

    Records.discussionReaders.fetch
      params:
        discussion_id: @discussion.id
    .then (records) =>
      userIds = map records['users'], 'id'
      Records.memberships.fetch
        path: 'autocomplete'
        exclude_types: 'group'
        params:
          group_id: @discussion.groupId
          user_ids: userIds.join(' ')
      .then => @updateSuggestions()

    @watchRecords
      collections: ['discussionReaders', 'memberships']
      query: (records) => @updateReaders()

  watch:
    query: -> @updateReaders()

  computed:
    model: -> @discussion

  methods:
    excludedUserIds: ->
      @readerUserIds.concat(Session.user().id)

    isGroupAdmin: (reader) ->
      @membershipsByUserId[reader.userId] && @membershipsByUserId[reader.userId].admin

    isGuest: (reader) ->
      !@membershipsByUserId[reader.userId]

    inviteRecipients: ->
      count = @recipients.length
      @saving = true
      Records.announcements.remote.post '',
        discussion_id: @discussion.id
        recipients:
          user_ids: map filter(@recipients, (r) -> r.type == 'user'), 'id'
          emails: map filter(@recipients, (r) -> r.type == 'email'), 'id'

      .then => @reset = !@reset
      .finally =>
        Flash.success('announcement.flash.success', { count: count })
        @saving = false

    newQuery: (query) -> @query = query
    newRecipients: (recipients) -> @recipients = recipients

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
      :users="users"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")
    .d-flex
      v-spacer
      v-btn.strand-members-list__submit(color="primary" :disabled="!recipients.length" @click="inviteRecipients" @loading="saving" v-t="'common.action.invite'")
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
