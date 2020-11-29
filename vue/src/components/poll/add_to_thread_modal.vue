<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import EventBus          from '@/shared/services/event_bus'
import I18n           from '@/i18n'
import { onError } from '@/shared/helpers/form'
import { sortBy, debounce } from 'lodash'

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

  mounted: ->
    Records.discussions.fetch
      path: 'dashboard'
      params:
        per: 50
    .then => @getSuggestions()

  methods:
    getSuggestions: ->
      @searchResults = Records.discussions.collection.chain()
        .find(groupId: @groupId)
        .where((d) -> !!AbilityService.canStartPoll(d))
        .simplesort('id', true)
        .data()

    submit: ->
      @poll.addToThread(@selectedDiscussion.id)
      .then =>
        @close()
        Flash.success('add_poll_to_thread_modal.success', pollType: @poll.translatedPollType())
      .catch onError(@poll)

    fetch: debounce ->
      return unless @searchFragment
      @loading = true
      Records.discussions.search(@groupId, @searchFragment).then (data) =>
        @loading = false
        @searchResults = Records.discussions.collection.chain()
          .find(groupId: @groupId)
          .find(title: { $regex: [@searchFragment, 'i'] })
          .where((d) -> !!AbilityService.canStartPoll(d))
          .simplesort('title')
          .data()
    , 500

  watch:
    searchFragment: 'fetch'
    groupId: 'getSuggestions'

</script>
<template lang="pug">
v-card
  submit-overlay(:value='poll.processing')
  v-card-title
    h1.headline(tabindex="-1" v-t="'action_dock.add_poll_to_thread'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-text="fullName" item-value="id")
    v-autocomplete.add-to-thread-modal__search(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-text="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')" :loading="loading")
  v-card-actions
    v-spacer
    v-btn.add-to-thread-modal__submit(color="primary" @click="submit()" :disabled="!selectedDiscussion" :loading="poll.processing")
      span(v-t="'common.action.save'")
</template>
