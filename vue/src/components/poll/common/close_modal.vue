<script lang="coffee">
import Records from '@/shared/services/records'
import { applySequence } from '@/shared/helpers/apply'

export default
  props:
    poll: Object
    close: Function
  data: ->
    isClosing: true
    isDisabled: false
  # created: ->
  #   applySequence $scope,
  #     steps: ['close', 'outcome', 'announce']
  #     closeComplete: ->
  #       $scope.outcome = Records.outcomes.build(pollId: $scope.poll.id)
  #     outcomeComplete: (_, event) ->
  #       $scope.announcement = Records.announcements.buildFromModel(event)

</script>
<template lang="pug">
v-card.poll-common-modal.lmo-modal__narrow
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    .md-toolbar-tools.lmo-flex__space-between
      h1.lmo-h1
        span(v-if='isClosing', v-t="'poll_common_close_form.close_' + poll.pollType")
        span(v-if='!isClosing', v-t="'poll_common_outcome_form.new_title'")
        //- span(ng-switch-when='announce', translate='announcement.form.outcome_announced.title')
      dismiss-modal-button(:close="close")
  v-card-text.lmo-slide-animation
    //- poll_common_close_form.animated(poll='poll', v-if='isClosing')
    //- poll-common-outcome-form.animated(:outcome='outcome' v-if="!isClosing")
    //- announcement_form.animated(announcement='announcement', ng-switch-when='announce')
  v-card-actions.lmp-slide-animation
    //- poll_common_close_form_actions.animated(poll='poll', ng-switch-when='close')
    //- poll-common-outcome-form-actions.animated(:outcome='outcome')

</template>
<style lang="scss">
</style>
