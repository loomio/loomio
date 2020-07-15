<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import EventBus          from '@/shared/services/event_bus'
import { onError } from '@/shared/helpers/form'
import { sortBy, debounce } from 'lodash-es'

export default
  data: ->
    selectedDiscussion: null
    searchFragment: ''
    searchResults: []
    groupId: @poll.groupId
    groups: sortBy(Session.user().groups(), 'fullName')
    loading: false

  props:
    poll: Object
    close: Function

  methods:
    submit: ->
      console.log 'submitting'
      # @loading = true
      # @selectedDiscussion.moveComments()
      # .then =>
      #   @loading = false
      #   @resetSourceDiscussion()
      #   @selectedDiscussion.update(forkedEventIds: [])
      #   @selectedDiscussion.update(isForking: false)
      #   @close()
      #   Flash.success("discussion_fork_actions.moved")
      # .catch onError(@selectedDiscussion)

    fetch: debounce ->
      return unless @searchFragment
      @loading = true
      Records.discussions.search(@groupId, @searchFragment).then (data) =>
        @loading = false
        @searchResults = Records.discussions.collection.chain()
          .find(groupId: @groupId)
          .find(title: { $regex: [@searchFragment, 'i'] })
          .where((d) -> !!AbilityService.canAddComment(d))
          .simplesort('title')
          .data()
    , 500

  watch:
    searchFragment: 'fetch'

</script>
<template lang="pug">
v-card
  submit-overlay(:value='loading')
  v-card-title
    h1.headline(v-t="'action_dock.add_poll_to_thread'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-text="fullName" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-text="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" v-t="'common.action.save'" :disabled="!selectedDiscussion")
</template>
