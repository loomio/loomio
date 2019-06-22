<style lang="scss">
.discussion-fork-actions {
  position: fixed;
  left: 0;
  width: 100%;
  z-index: 10;
}

.discussion-fork-actions__notice {
  padding: 8px;
}
</style>

<script lang="coffee">
import Records      from '@/shared/services/records.coffee'
import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'

export default
  mixins: [DiscussionModalMixin]
  props:
    discussion: Object
  methods:
    submit: ->
      @openForkedDiscussionModal(@discussion)
      @discussion.forkedEventIds = []
</script>

<template lang='pug'>
.discussion-fork-actions.lmo-drop-animation
  .discussion-fork-actions__notice.animated.lmo-card.lmo-flex--row.lmo-flex__center(v-show='discussion.isForking()')
    v-icon.mdi.mdi-18px.lmo-margin-right mdi-call-split
    span.lmo-flex__grow(v-t="'discussion_fork_actions.helptext'")
    v-btn.md-accent(@click='discussion.forkedEventIds = []', v-t="'common.action.cancel'")
    v-btn.discussion-fork-actions__submit(@click='submit()', v-t="'common.action.fork'")
</template>
