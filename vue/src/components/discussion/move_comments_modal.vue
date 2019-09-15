<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { submitDiscussion } from '@/shared/helpers/form'
import { orderBy } from 'lodash'

export default
  data: ->
    selectedDiscussion: null
    submit: null
    searchFragment: null
    searchResults: []
    groupId: @discussion.groupId
    groups: Session.user().formalGroups()

  props:
    discussion: Object
    close: Function

  methods:
    setSubmit: ->
      @selectedDiscussion.update(isForking: true)
      @selectedDiscussion.update(forkedEventIds: @discussion.forkedEventIds)
      @submit = submitDiscussion @, @selectedDiscussion,
        successCallback: (data) =>
          @discussion.update(forkedEventIds: [])
          @discussion.update(isForking: false)
          @selectedDiscussion.update(forkedEventIds: [])
          @selectedDiscussion.update(isForking: false)
          @close()
          @$router.push @urlFor(@selectedDiscussion)


  watch:
    selectedDiscussion: 'setSubmit'
    searchFragment: (fragment) ->
      return unless fragment.length
      Records.discussions.search(@groupId, fragment).then (data) =>
        @searchResults = Records.discussions.collection.chain()
          .find(groupId: @groupId)
          .find({ id: { $ne: @discussion.id } })
          .find(title: { $regex: [fragment, 'i'] })
          .where((d) -> AbilityService.canMoveThread(d))
          .data()

</script>
<template lang="pug">
v-card
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline(v-t="'action_dock.move_comments'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-select(v-model="groupId" :items="groups" item-text="name" item-value="id")
    v-autocomplete(hide-no-data return-object v-model="selectedDiscussion" :search-input.sync="searchFragment" :items="searchResults" item-text="title" :placeholder="$t('discussion_fork_actions.search_placeholder')")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" v-t="'common.action.save'" :disabled="!selectedDiscussion")
</template>
