<script lang="coffee">
import Records from '@/shared/services/records'
import { applySequence } from '@/shared/helpers/apply'
import { iconFor }       from '@/shared/helpers/poll'

export default
  props:
    poll: Object
    close: Function
  data: ->
    isDisabled: false
  methods:
    icon: ->
      iconFor(@poll)
</script>
<template lang="pug">
v-card.poll-common-modal
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    .md-toolbar-tools.lmo-flex__space-between
      v-icon icon()
      h1.lmo-h1(v-t="'poll_common_reopen_form.title'")
      dismiss-modal-button(:close="close")
  v-card-text
    .lmo-slide-animation
      .poll-common-reopen-form
        span.lmo-hint-text(v-t="'poll_common_reopen_form.helptext'")
        poll-common-closing-at-field(:poll='poll')

    //- dialog_scroll_indicator
  v-card-actions.lmo-slide-animation
    //- poll_common_reopen_form_actions.animated(poll='poll')
</template>
<style lang="scss">
</style>
