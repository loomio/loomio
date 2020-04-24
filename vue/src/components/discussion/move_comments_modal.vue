<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import EventBus          from '@/shared/services/event_bus'
import { onError } from '@/shared/helpers/form'
import { orderBy, debounce } from 'lodash-es'

export default
  data: ->
    selectedDiscussion: null
    searchFragment: ''
    searchResults: []
    groupId: @discussion.groupId
    groups: Session.user().groups()

  props:
    discussion: Object
    close: Function

  methods:
    resetSourceDiscussion: ->
      @discussion.update(forkedEventIds: [])
      @discussion.update(isForking: false)

    startNewThread: ->
      @selectedDiscussion = Records.discussions.build(groupId: @groupId)
      @setIsForking()
      @resetSourceDiscussion()
      EventBus.$emit('openModal',
                      component: 'DiscussionForm',
                      props: {
                        discussion: @selectedDiscussion
                      })

    submit: ->
      @selectedDiscussion.moveComments()
      .then =>
        @resetSourceDiscussion()
        @selectedDiscussion.update(forkedEventIds: [])
        @selectedDiscussion.update(isForking: false)
        @close()
        Flash.success("discussion_fork_actions.moved")
      .catch onError(@selectedDiscussion)

    setIsForking: ->
      @selectedDiscussion.update(isForking: true)
      @selectedDiscussion.update(forkedEventIds: @discussion.forkedEventIds)

    fetch: debounce ->
      return unless @searchFragment
      Records.discussions.search(@groupId, @searchFragment).then (data) =>
        @searchResults = Records.discussions.collection.chain()
          .find(groupId: @groupId)
          .find({ id: { $ne: @discussion.id } })
          .find(title: { $regex: [@searchFragment, 'i'] })
          .where((d) -> AbilityService.canMoveThread(d))
          .simplesort('title')
          .data()
    , 500

  watch:
    selectedDiscussion: 'setIsForking'
    searchFragment: 'fetch'

</script>
<template lang="pug">
v-card
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline(v-t="'action_dock.move_items'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-text="name" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-text="title" :placeholder="$t('discussion_fork_actions.search_placeholder')" :label="$t('discussion_fork_actions.move_to_existing_thread')")
  v-card-actions
    v-spacer
    v-btn(color="accent" @click="startNewThread()" v-t="'discussion_fork_actions.start_new_thread'")
    v-btn(color="primary" @click="submit()" v-t="'common.action.save'" :disabled="!selectedDiscussion")
</template>
