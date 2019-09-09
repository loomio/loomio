<script lang="coffee">
import Records      from '@/shared/services/records.coffee'
# import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'
import openModal      from '@/shared/helpers/open_modal'

export default
  # mixins: [DiscussionModalMixin]
  props:
    discussion: Object
  methods:
    # submit: ->
      # @openForkedDiscussionModal(@discussion)
      # @discussion.forkedEventIds = []

    openMoveCommentsModal: ->
      openModal
        component: 'MoveCommentsModal'
        props:
          discussion: @discussion

    openNewDiscussionModal: ->
      openModal
        component: 'DiscussionForm'
        props:
          discussion: Records.discussions.build
            groupId:        @discussion.groupId
            private:        @discussion.private
            forkedEventIds: @discussion.forkedEventIds
            description: @discussion.description
            descriptionFormat: @discussion.descriptionFormat
      @discussion.forkedEventIds = []
</script>

<template lang='pug'>
v-banner.discussion-fork-actions(sticky v-model='discussion.isForking()' icon="mdi-call-split")
  span(v-t="'discussion_fork_actions.helptext'")
  template(v-slot:actions)
    v-btn(@click='discussion.forkedEventIds = []')
      v-icon mdi-close
    v-btn(@click="openMoveCommentsModal()") Existing thread
    v-btn(@click="openNewDiscussionModal()") New thread
    //- v-btn.discussion-fork-actions__submit(@click='submit()', v-t="'common.action.fork'" color="primary")
</template>
