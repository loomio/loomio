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

  mounted: ->
    # TODO add query support to this fetch for when there are many readers
    Records.discussionReaders.fetch
      params:
        discussion_id: @discussion.id

    @watchRecords
      collections: ['discussionReaders']
      query: (records) => @updateReaders()

  watch:
    query: -> @updateReaders()

  methods:
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
  dismiss-modal-button
  discussion-privacy-badge.pa-4(:discussion="discussion")
  recipients-autocomplete(
    show-groups
    label="invite"
    placeholder="enter names or email addresses of people to invite to the thread"
    :group="discussion.group()"
    :excluded-user-ids="excludedUserIds"
    @new-query="newQuery"
    @new-recipients="newRecipients")
  v-list
    v-subheader Participants
    v-list-item(v-for="reader in readers" :user="reader.user()" :key="reader.id")
      v-list-item-avatar
        user-avatar(:user="reader.user()")
      v-list-item-content
        v-list-item-title
          span.mr-2 {{reader.user().nameWithTitle(discussion.group())}}
          v-chip(v-if="reader.admin" outlined x-small label v-t="'members_panel.admin'")
        //- v-list-item-subtitle Admin
      v-list-item-icon
        v-icon mdi-horizontal-dots
</template>

<style lang="sass">
</style>
