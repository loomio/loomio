<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import {map, debounce, without} from 'lodash'

export default
  props:
    discussion: Object

  data: ->
    readers: []
    query: ''
    searchResults: []
    invitedUserIds: []


  mounted: ->
    @search = debounce ->
      return unless @query && @query.length > 2
      Records.users.fetchMentionable(@query, @discussion.group())

    Records.discussionReaders.fetch
      path: ''
      params:
        discussion_id: @discussion.id

    @watchRecords
      collections: ['memberships']
      query: (records) => @updateSearchResults()

    @watchRecords
      collections: ['discussionReaders']
      query: (records) => @updateReaders()

  watch:
    query: (q) ->
      @search(q)
      @updateReaders()
      @updateSearchResults()

  methods:
    openInviteModal: ->
      EventBus.$emit 'openModal',
        component: 'StrandMembersList',
        props: { discussion: discussion }

    remove: (item) ->
      @discussion.recipientIds = without(@discussion.recipientIds, item.id)

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

    updateSearchResults: ->
      memberIds = without(@discussion.group().memberIds(), Session.user().id)
      chain = Records.users.collection.chain().find(id: {$in: memberIds})
      if @query
        chain = chain.find(
          $or: [
            {name: {'$regex': ["^#{@query}", "i"]}},
            {username: {'$regex': ["^#{@query}", "i"]}},
            {name: {'$regex': [" #{@query}", "i"]}}
          ]
        )
      @searchResults = chain.simplesort('name').data()

</script>

<template lang="pug">
.strand-members-list
  discussion-privacy-badge.pa-4(:discussion="discussion")
  v-autocomplete.px-4(multiple chips hide-no-data hide-selected no-filter v-model='invitedUserIds' @change="query= ''" :search-input.sync="query" item-text='name' item-value="id" item-avatar="avatar_url.large" :label="$t('discussion_form.invite')" :items='searchResults')
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
