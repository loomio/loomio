<script lang="coffee">
import Records from '@/shared/services/records'
import { applySequence } from '@/shared/helpers/apply'
import { submitOutcome, eventKind } from '@/shared/helpers/form'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import PollModalMixin from '@/mixins/poll_modal'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

export default
  mixins: [PollModalMixin, AnnouncementModalMixin]
  props:
    outcome: Object
    close: Function
  data: ->
    isDisabled: false
  created: ->
    @submit = submitOutcome @, @outcome,
      successCallback: (data) =>
        eventData = _.find(data.events, (event) => event.kind == eventKind(@outcome)) || {}
        event = Records.events.find(eventData.id)
        @closeModal()
        @openAnnouncementModal(Records.announcements.buildFromModel(event))
  methods:
    datesAsOptions: ->
      fieldFromTemplate @outcome.poll().pollType, 'dates_as_options'

</script>

<template lang="pug">
v-card.poll-common-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='outcome.processing')
  v-card-title
    h1.headline
      span(v-if='outcome.isNew()' v-t="'poll_common_outcome_form.new_title'")
      span(v-if='!outcome.isNew()' v-t="'poll_common_outcome_form.update_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  .poll-common-outcome-form.px-6.py-4
    poll-common-calendar-invite(:outcome='outcome', v-if='datesAsOptions()')
    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='outcome' field='statement' :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
      template(v-slot:actions)
        v-btn.poll-common-outcome-form__submit(color="primary" @click='submit()' v-t="'common.action.save'")
    validation-errors(:subject="outcome" field="statement")
</template>
