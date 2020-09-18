<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import {map, debounce, without, filter, uniq, uniqBy} from 'lodash'

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
      collections: ['discussionReaders']
      query: (records) => @updateReaders()

    @watchRecords
      collections: ['memberships']
      query: (records) =>
        @membershipsByUserId = {}
        userIds = map(Records.discussionReaders.collection.
                      find(discussionId: @discussion.id), 'userId')
        Records.memberships.collection.find(userId: {$in: userIds}).forEach (m) =>
          @membershipsByUserId[m.userId] = m

  watch:
    query: -> @updateReaders()

  methods:
    isAdmin: (reader) ->
      reader.admin || @membershipsByUserId[reader.userId] && @membershipsByUserId[reader.userId].admin

    isGuest: (reader) ->
      !@membershipsByUserId[reader.userId]

    inviteRecipients: ->
      Records.announcements.remote.post '',
        discussion_id: @discussion.id
        recipients:
          user_ids: map filter(@recipients, (r) -> r.type == 'user'), 'id'
          emails: map filter(@recipients, (r) -> r.type == 'email'), 'id'

    newQuery: (query) -> @query = query
    newRecipients: (recipients) -> @recipients = recipients

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
      @excludedUserIds = map(@readers, 'userId').concat(Session.user().id)

</script>

<template lang="pug">
.strand-members-list
  .pa-3
    dismiss-modal-button
    discussion-privacy-badge(:discussion="discussion")
    recipients-autocomplete(
      label="invite"
      placeholder="enter names or email addresses of people to invite to the thread"
      :group="discussion.group()"
      :excluded-user-ids="excludedUserIds"
      @new-query="newQuery"
      @new-recipients="newRecipients")
    .d-flex
      v-btn(:disabled="!recipients.length" @click="inviteRecipients") Invite

  v-list
    v-subheader Participants
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      v-list-item-avatar
        user-avatar(:user="reader.user()")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{reader.user().nameWithTitle(discussion.group())}}
          v-chip(v-if="isGuest(reader)" outlined x-small label v-t="'members_panel.guest'")
          v-chip(v-if="isAdmin(reader)" outlined x-small label v-t="'members_panel.admin'")
        //- v-list-item-subtitle Admin
      v-list-item-icon
        v-icon mdi-horizontal-dots
</template>

<style lang="sass">
</style>
