<script lang="coffee">
import Records from '@/shared/services/records'
import { submitDiscussion } from '@/shared/helpers/form'

export default
  data: ->
    discussions: []
    selectedDiscussion: null
    submit: null
  props:
    discussion: Object
    close: Function
  mounted: ->
    Records.discussions.fetchByGroup(@discussion.groupId).then () =>
      @discussions = Records.discussions.collection.data.filter((discussion) => discussion.groupId == @discussion.groupId && discussion.id != @discussion.id)
  methods:
    setSubmit: ->
      @selectedDiscussion.update(isForking: true)
      @selectedDiscussion.update(forkedEventIds: @discussion.forkedEventIds)
      @submit = submitDiscussion @, @selectedDiscussion,
        successCallback: (data) =>
          @discussion.update(forkedEventIds: [])
          @discussion.update(isForking: false)
          discussionKey = data.discussions[0].key
          Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
            discussion.update(forkedEventIds: [])
            discussion.update(isForking: false)
            @close()
            @$router.push @urlFor(discussion)
  watch:
    selectedDiscussion: 'setSubmit'
</script>
<template lang="pug">
v-card
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline(v-t="'action_dock.move_comments'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-select(return-object v-model="selectedDiscussion" :items="discussions" item-text="title" placeholder="Select the discussion you want to move these comments to")
  v-card-actions
    v-spacer
      v-btn(color="primary" @click="submit()" v-t="'common.action.save'" :disabled="!selectedDiscussion")
</template>
