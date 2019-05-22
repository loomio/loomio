<script lang="coffee">
import Records from '@/shared/services/records'
import { iconFor }                from '@/shared/helpers/poll'
import { applyPollStartSequence } from '@/shared/helpers/apply'

export default
  props:
    poll: Object
    close: Function
  data: ->
    announcement: {}
  created: ->
    applyPollStartSequence @,
      afterSaveComplete: (event) =>
        @announcement = Records.announcements.buildFromModel(event)
  methods:
    icon: ->
      iconFor(@poll)

</script>
<template lang="pug">
  v-card.poll-common-modal
    // <div ng-show="isDisabled" class="lmo-disabled-form"></div>
    v-card-title
      h1.lmo-h1
        span(v-t="'poll_common.start_poll'")
      dismiss-modal-button(:close='close')
    v-card-text
      .lmo-slide-animation
        poll-common-directive.animated(:poll='poll', name='form', :modal='true')
      // <dialog_scroll_indicator></dialog_scroll_indicator>
    v-card-actions.lmo-slide-animation
      poll-common-form-actions.animated(:poll='poll', :close='close')
</template>
