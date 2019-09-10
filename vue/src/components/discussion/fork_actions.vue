<script lang="coffee">
import Records      from '@/shared/services/records.coffee'
# import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'
import openModal      from '@/shared/helpers/open_modal'

export default
  # mixins: [DiscussionModalMixin]
  props:
    discussion: Object
  methods:
    openMoveCommentsModal: ->
      openModal
        component: 'MoveCommentsModal'
        props:
          discussion: @discussion

    openNewDiscussionModal: ->
      newDiscussion = Records.discussions.build
        groupId:        @discussion.groupId
        private:        @discussion.private
        forkedEventIds: @discussion.forkedEventIds
        description: @discussion.description
        descriptionFormat: @discussion.descriptionFormat
        isForking: true
      openModal
        component: 'DiscussionForm'
        props:
          discussion: newDiscussion
      @discussion.update(forkedEventIds: [])
      @discussion.update(isForking: false)
</script>

<template lang='pug'>
v-banner.discussion-fork-actions(sticky v-model='discussion.isForking' icon="mdi-call-split")
  span(v-t="'discussion_fork_actions.helptext'")
  template(v-slot:actions)
    v-btn(@click="openMoveCommentsModal()" v-t="'discussion_fork_actions.existing_thread'")
    v-btn(@click="openNewDiscussionModal()" v-t="'discussion_fork_actions.new_thread'")
    v-btn(icon @click='discussion.forkedEventIds = []; discussion.isForking = false')
      v-icon mdi-close
</template>
