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
Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

module.exports =
  props:
    discussion: Object
  methods:
    submit: ->
      ModalService.open 'DiscussionStartModal', discussion: =>
        Records.discussions.build
          groupId:        @discussion.groupId
          private:        @discussion.private
          forkedEventIds: @discussion.forkedEventIds
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
