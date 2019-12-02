<script lang="coffee">
import Records from '@/shared/services/records'
import { applySequence } from '@/shared/helpers/apply'
import { submitOutcome, eventKind } from '@/shared/helpers/form'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import PollModalMixin from '@/mixins/poll_modal'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

import Vue     from 'vue'
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import { map, sortBy, head, find } from 'lodash'

export default
  mixins: [PollModalMixin, AnnouncementModalMixin]

  props:
    outcome: Object
    close: Function

  data: ->
    options: []
    bestOption: null
    clone: null
    isDisabled: false

  created: ->
    @clone = @outcome.clone()

    if @datesAsOptions()
      @options = map @clone.poll().pollOptions(), (option) ->
        id:        option.id
        value:     exact(parseISO(option.name))
        attendees: option.stances().length

      @bestOption = head sortBy @options, (option) ->
        -1 * option.attendees # sort descending, so the best option is first

      Vue.set(@clone, 'calendarInvite', true)

      @clone.pollOptionId = @outcome.pollOptionId or @bestOption.id
      @clone.customFields.event_summary = @clone.customFields.event_summary or @clone.poll().title

    @submit = submitOutcome @, @clone,
      prepareFn: (prepareArgs) =>
        @clone.customFields.should_send_calendar_invite = @clone.calendarInvite
        @clone.customFields.event_description = @clone.statement if @datesAsOptions()
      successCallback: (data) =>
        eventData = find(data.events, (event) => event.kind == 'outcome_created') || {}
        event = Records.events.find(eventData.id)
        @closeModal()
        @openAnnouncementModal(Records.announcements.buildFromModel(event))

  methods:
    datesAsOptions: ->
      fieldFromTemplate @clone.poll().pollType, 'dates_as_options'

</script>

<template lang="pug">
v-card.poll-common-outcome-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='clone.processing')
  v-card-title
    h1.headline
      span(v-if='clone.isNew()' v-t="'poll_common_outcome_form.new_title'")
      span(v-if='!clone.isNew()' v-t="'poll_common_outcome_form.update_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  .poll-common-outcome-form.px-6.py-4

    .poll-common-calendar-invite(v-if='datesAsOptions()')
      .poll-common-calendar-invite__checkbox.poll-common-checkbox-option
        v-checkbox(v-model='clone.calendarInvite' :label="$t('poll_common_calendar_invite.calendar_invite')")
      .poll-common-calendar-invite__form.animated(v-if='clone.calendarInvite')
        .poll-common-calendar-invite--pad-top
          v-select.lmo-flex__grow(v-model='clone.pollOptionId' :items="options" item-value="id" item-text="value" :label="$t('poll_common_calendar_invite.poll_option_id')")
        .poll-common-calendar-invite--pad-top
          v-text-field.poll-common-calendar-invite__summary(type='text' :placeholder="$t('poll_common_calendar_invite.event_summary_placeholder')" v-model='clone.customFields.event_summary' :label="$t('poll_common_calendar_invite.event_summary')")
          validation-errors(:subject='clone', field='event_summary')
          v-text-field.poll-common-calendar-invite__location(type='text' :placeholder="$t('poll_common_calendar_invite.location_placeholder')" v-model='clone.customFields.event_location' :label="$t('poll_common_calendar_invite.location')")
          //- v-textarea.md-input.poll-common-calendar-invite__description(type='text' :placeholder="$t('poll_common_calendar_invite.event_description_placeholder')" v-model='clone.customFields.event_description' :label="$t('poll_common_calendar_invite.event_description')")



    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='clone' field='statement' :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
      template(v-slot:actions)
        v-btn.poll-common-outcome-form__submit(color="primary" @click='submit()' v-t="'common.action.save'")
    validation-errors(:subject="clone" field="statement")
</template>
