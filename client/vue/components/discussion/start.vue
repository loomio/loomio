<script lang="coffee">
Records = require 'shared/services/records'
{ applyDiscussionStartSequence } = require 'shared/helpers/apply'

module.exports =
  props:
    discussion: Object
    close: Function
  data: ->
    announcement: {}
  created: ->
    applyDiscussionStartSequence @,
      afterSaveComplete: (event) =>
        @announcement = Records.announcements.buildFromModel(event)
</script>

<template>
  <v-card class="discussion-modal">
    <!-- <div v-show="isDisabled" class="lmo-disabled-form"></div> -->
    <v-card-title>
      <div class="md-toolbar-tools lmo-flex lmo-flex__space-between">
        <i class="mdi mdi-forum"></i>
        <h1 class="lmo-h1 modal-title">
          <span v-t="'discussion_form.new_discussion_title'" v-if="currentStep == 'save' && !discussion.isForking()"></span>
          <span v-t="'discussion_form.fork_discussion_title'" v-if="currentStep == 'save' && discussion.isForking()"></span>
          <span v-t="'announcement.form.discussion_announced.title'" v-if="currentStep == 'announce'"></span>
        </h1>
        <dismiss-modal-button aria-hidden="true" :close="close"></dismiss-modal-button>
      </div>
    </v-card-title>
    <v-card-text class="md-body-1 lmo-slide-animation">
      <discussion-form :discussion="discussion" v-if="currentStep == 'save'" class="animated"></discussion-form>
      <!-- <announcement_form :announcement="announcement" v-if="currentStep == announce"></announcement_form> -->
    </v-card-text>
    <v-card-actions>
      <discussion-form-actions :discussion="discussion" :close="close" v-if="currentStep == 'save'"></discussion-form-actions>
      <!-- <announcement_form_actions announcement="announcement" v-if="currentStep == announce"></announcement_form_actions> -->
    </v-card-actions>
  </v-card>
</template>

<style lang="scss">
</style>
