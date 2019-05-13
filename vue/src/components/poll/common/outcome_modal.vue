<script lang="coffee">
import Records from '@/shared/services/records'
import { applySequence } from '@/shared/helpers/apply'

export default
  props:
    outcome: Object
    close: Function
  data: ->
    isDisabled: false
</script>
<template lang="pug">
v-card.poll-common-modal
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    .md-toolbar-tools.lmo-flex__space-between
      v-icon mdi-thumbs-up-down
      h1.lmo-h1
        span(v-if='outcome.isNew()' v-t="'poll_common_outcome_form.new_title'")
        span(v-if='!outcome.isNew()' v-t="'poll_common_outcome_form.update_title'")
        //- span(ng-switch-when='announce', translate='announcement.form.outcome_announced.title')
      dismiss-modal-button(:close="close")
  v-card-text.lmo-slide-animation
    //- poll_common_outcome_form.animated(:outcome='outcome')
    //- announcement_form.animated(announcement='announcement', ng-switch-when='announce')
  v-card-actions.lmo-slide-animation
    //- poll_common_outcome_form_actions.animated(outcome='outcome')
</template>
<style lang="scss">
</style>
