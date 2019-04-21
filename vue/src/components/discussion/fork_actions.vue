<style lang="scss">
@import 'variables';
.discussion-fork-actions {
  position: fixed;
  left: 0;
  width: 100%;
  z-index: $z-low;
}

.discussion-fork-actions__notice {
  padding: 8px;
}
</style>

<script lang="coffee">
import Records      from '@/shared/services/records.coffee'
import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'

export default
  props:
    discussion: Object
  methods:
    submit: ->
      @openForkedDiscussionModal(@discussion)
</script>

<template>
  <div class="discussion-fork-actions lmo-drop-animation">
    <div v-show="discussion.isForking()" class="discussion-fork-actions__notice animated lmo-card lmo-flex--row lmo-flex__center">
      <i class="mdi mdi-call-split mdi-18px lmo-margin-right"></i>
      <span v-t="'discussion_fork_actions.helptext'" class="lmo-flex__grow"></span>
      <v-btn @click="discussion.forkedEventIds = []" v-t="'common.action.cancel'" class="md-accent"></v-btn>
      <v-btn @click="submit()" v-t="'common.action.fork'" class="md-primary md-raised discussion-fork-actions__submit"></v-btn>
    </div>
  </div>
</template>
