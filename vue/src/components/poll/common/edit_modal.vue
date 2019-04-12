<style lang="scss">
.poll-common-modal {
  background-color: 'white';
}
</style>
<script lang="coffee">
import Records from '@/shared/services/records'
import { iconFor }       from '@/shared/helpers/poll'
import { applySequence } from '@/shared/helpers/apply'

export default
  props:
    poll: Object
    close: Function
  data: ->
    dpoll: @poll.clone()
    announcement: {}
    currentStep: 'save'
  created: ->
    # applySequence $scope,
    #   steps: ['save', 'announce']
    #   saveComplete: (_, event) ->
        # @announcement = Records.announcements.buildFromModel(event)
  computed:
    icon: ->
      iconFor(@poll)
</script>
<template lang="pug">

v-card.poll-common-modal
  v-card-title
    v-icon.mdi(:class="icon")
    h1.lmo-h1
      span(v-t="'poll_' + poll.pollType + '_form.edit_header'", v-if="currentStep == 'save'")
      span(v-t="announcement.form.poll.title", v-if="currentStep == 'announce'")
    dismiss-modal-button(:close="close")
  v-card-text
    poll-common-directive(:poll="poll", name="form", v-if="currentStep == 'save'")
    announcement-form(announcement="announcement", v-if="currentStep == 'announce'")
    //- dialog_scroll_indicator
  v-card-actions
    poll-common-form-actions(:poll="poll", v-if="currentStep == 'save'")
    announcement-form-actions(:announcement="announcement", v-if="currentStep == 'announce'")
</template>
