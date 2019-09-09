<script lang="coffee">
import Records      from '@/shared/services/records.coffee'
# import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'
import openModal      from '@/shared/helpers/open_modal'

export default
  # mixins: [DiscussionModalMixin]
  props:
    discussion: Object
  methods:
    submit: ->
      # @openForkedDiscussionModal(@discussion)
      # @discussion.forkedEventIds = []
      openModal
        component: 'MoveCommentModal'
        props:
          discussion: @discussion

      openEditDiscussionModal: ->
        openModal
          component: 'DiscussionForm'
            props:
              discussion: @discussion
      openNewDiscussionModal: ->
        openModal
          component: 'DiscussionForm'
            props:
              discussion: Records.discussions.build
                groupId:        @discussion.groupId
                forkedEventIds: @discussion.forkedEventIds
</script>

<template lang='pug'>
v-banner.discussion-fork-actions(sticky v-model='discussion.isForking()' icon="mdi-call-split")
  span(v-t="'discussion_fork_actions.helptext'")
  template(v-slot:actions)
    v-btn(@click='discussion.forkedEventIds = []')
      v-icon mdi-close
    v-btn(@click="openEditDiscussionModal()") Move comments to existing thread
    v-btn(@click="openNewDiscussionModal()") Move comments to new thread
    //- v-btn.discussion-fork-actions__submit(@click='submit()', v-t="'common.action.fork'" color="primary")
</template>
