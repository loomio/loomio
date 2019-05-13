<script lang="coffee">
import Records from '@/shared/services/records'
import { applySequence } from '@/shared/helpers/apply'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import { submitOutcome } from '@/shared/helpers/form'
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
  props:
    outcome: Object
    close: Function
  data: ->
    isDisabled: false
  created: ->
    @submit = submitOutcome @, @outcome,
      successCallback: => @closeModal()
  methods:
    datesAsOptions: ->
      fieldFromTemplate @outcome.poll().pollType, 'dates_as_options'
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
    .poll-common-outcome-form
      .lmo-disabled-form(v-if='isDisabled')
      .md-block
        label(v-t="'poll_common.statement'")
        lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='outcome', field='statement', :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
        poll-common-calendar-invite(:outcome='outcome', v-if='datesAsOptions()')

    //- announcement_form.animated(announcement='announcement', ng-switch-when='announce')
  v-card-actions.lmo-slide-animation
    .lmo-md-actions
      v-btn.md-raised.md-primary.poll-common-outcome-form__submit(@click='submit()', v-t="'poll_common_outcome_form.submit'")
</template>
