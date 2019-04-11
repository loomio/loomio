<script lang="coffee">
import Records from '@/shared/services/records'
import { iconFor }                from '@/shared/helpers/poll'
import { applyPollStartSequence } from '@/shared/helpers/apply'

export default
  props:
    poll: Object
    close: Function
  data: ->
    dpoll: @poll.clone()
    announcement: {}
  created: ->
    applyPollStartSequence @,
      afterSaveComplete: (event) =>
        @announcement = Records.announcements.buildFromModel(event)
  methods:
    icon: ->
      iconFor(@poll)

</script>
<template>
  <v-card class="poll-common-modal">
    <!-- <div ng-show="isDisabled" class="lmo-disabled-form"></div> -->
    <v-card-title>
      <div class="md-toolbar-tools lmo-flex__space-between"><i :class="'mdi '+ icon()"></i>
        <h1 class="lmo-h1">
          <span v-if="currentStep == 'choose'" v-t="'poll_common.start_poll'"></span>
          <span v-if="currentStep == 'save'" v-t="'poll_common.start_poll'"></span>
          <span v-if="currentStep == 'announce'" v-t="'announcement.form.poll_announced.title'"></span>
        </h1>
        <dismiss-modal-button :close="close"></dismiss-modal-button>
      </div>
    </v-card-title>
    <v-card-text>
      <div class="lmo-slide-animation">
        <poll-common-choose-type v-if="currentStep == 'choose'" :poll="poll" class="animated"></poll-common-choose-type>
        <poll-common-directive v-if="currentStep == 'save'" :poll="poll" name="form" :modal="true" class="animated"></poll-common-directive>
        <announcement-form v-if="currentStep == 'announce'" :announcement="announcement" class="animated"></announcement-form>
      </div>
      <!-- <dialog_scroll_indicator></dialog_scroll_indicator> -->
    </v-card-text>
    <v-card-actions v-if="currentStep != 'choose'" class="lmo-slide-animation">
      <poll-common-form-actions v-if="currentStep == 'save'" :poll="poll" :close="close" class="animated"></poll-common-form-actions>
      <announcement-form-actions v-if="currentStep == 'announce'" :announcement="announcement" class="animated"></announcement-form-actions>
    </v-card-actions>
  </v-card>
</template>
