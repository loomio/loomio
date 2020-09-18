<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
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
    excludedUserIds: []
    membershipsByUserId: {}
    readerUserIds: []
    reset: false
    saving: false

  mounted: ->
    # TODO add query support to this fetch for when there are many readers
    Records.discussionReaders.fetch
      params:
        discussion_id: @discussion.id
    .then (records) =>
      userIds = map records['users'], 'id'
      Records.memberships.fetch
        path: 'autocomplete'
        params:
          group_id: @discussion.groupId
          user_ids: userIds.join(' ')

    @watchRecords
      collections: ['discussionReaders', 'memberships']
      query: (records) => @updateReaders()

    @watchRecords
      collections: ['memberships']
      query: (records) =>

  watch:
    query: -> @updateReaders()

  computed:
    anyGuests: ->
      some @readerUserIds, (userId) => !@membershipsByUserId[userId]

  methods:
    isAdmin: (reader) ->
      reader.admin || @membershipsByUserId[reader.userId] && @membershipsByUserId[reader.userId].admin

    isGuest: (reader) ->
      !@membershipsByUserId[reader.userId]

    inviteRecipients: ->
      @saving = true
      Records.announcements.remote.post '',
        discussion_id: @discussion.id
        recipients:
          user_ids: map filter(@recipients, (r) -> r.type == 'user'), 'id'
          emails: map filter(@recipients, (r) -> r.type == 'email'), 'id'

      .then => @reset = !@reset
      .finally => @saving = false

    newQuery: (query) -> @query = query
    newRecipients: (recipients) -> @recipients = recipients

    updateReaders: ->
      chain = Records.discussionReaders.collection.chain().
              find(discussionId: @discussion.id)

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
      @excludedUserIds = @readerUserIds.concat(Session.user().id)

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
      autofocus
      :label="$t('announcement.form.discussion_announced.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :group="discussion.group()"
      :excluded-user-ids="excludedUserIds"
      :reset="reset"
      @new-query="newQuery"
      @new-recipients="newRecipients")
    .d-flex
      v-spacer
      v-btn(color="primary" :disabled="!recipients.length" @click="inviteRecipients" @loading="saving" v-t="'common.action.invite'")
  v-list
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
          v-chip(v-if="isGuest(reader)" outlined x-small label v-t="'members_panel.guest'" :title="$t('announcement.inviting_guests_to_thread')")
          v-chip(v-if="isAdmin(reader)" outlined x-small label v-t="'members_panel.admin'")
        //- v-list-item-subtitle Admin
      //- v-list-item-action
      //-   v-icon mdi-dots-horizontal
</template>

<style lang="sass">
</style>
