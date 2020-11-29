<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import Flash from '@/shared/services/flash'
import EventBus from '@/shared/services/event_bus'
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'

import Vue     from 'vue'
import { uniq, map, sortBy, head, find, filter, sum } from 'lodash'
import { onError } from '@/shared/helpers/form'
import { format, formatDistance, parse, startOfHour, isValid, addHours, isAfter, parseISO } from 'date-fns'
import { hoursOfDay, exact} from '@/shared/helpers/format_time'

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    outcome: Object
    close: Function

  data: ->
    options: []
    bestOption: null
    isDisabled: false
    review: false
    isShowingDatePicker: false
    dateToday: format(new Date, 'yyyy-MM-dd')

  created: ->
    if @datesAsOptions()
      @options = map @outcome.poll().pollOptions(), (option) ->
        id:        option.id
        value:     exact(parseISO(option.name))
        attendees: option.stances().length

      @bestOption = head sortBy @options, (option) ->
        -1 * option.attendees # sort descending, so the best option is first

      Vue.set(@outcome, 'calendarInvite', true)

      @outcome.pollOptionId = @outcome.pollOptionId or @bestOption.id
      @outcome.customFields.event_summary = @outcome.customFields.event_summary or @outcome.poll().title

  methods:

    submit: ->
      @outcome.customFields.should_send_calendar_invite = @outcome.calendarInvite
      @outcome.customFields.event_description = @outcome.statement if @datesAsOptions()

      if @outcome.isNew()
        actionName = "created"
      else
        actionName = "updated"

      @outcome.save()
      .then (data) =>
        Flash.success("poll_common_outcome_form.outcome_#{actionName}")
        @closeModal()

      .catch onError(@outcome)

    datesAsOptions: ->
      fieldFromTemplate @outcome.poll().pollType, 'dates_as_options'

    newRecipients: (val) ->
      @recipients = val
      @outcome.recipientAudience = (val.find((i) -> i.type=='audience') || {}).id
      @outcome.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @outcome.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

</script>

<template lang="pug">
v-card.poll-common-outcome-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value='outcome.processing')
  v-card-title
    h1.headline
      span(v-if='outcome.isNew()' v-t="'poll_common_outcome_form.new_title'")
      span(v-if='!outcome.isNew()' v-t="'poll_common_outcome_form.update_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  .poll-common-outcome-form.px-4
    p(v-t="'announcement.form.outcome_announced.helptext'")
    recipients-autocomplete(
      :label="$t('action_dock.notify')"
      :placeholder="$t('poll_common_outcome_form.who_to_notify')"
      :model="outcome")

    //- .caption.outcome-modal__number-notified(v-if="notificationsCount != 1" v-t="{ path: 'poll_common_notify_group.members_count', args: { count: notificationsCount } }")
    //- .caption.outcome-modal__number-notified(v-else v-t="'discussion_form.one_person_notified'")

    .poll-common-calendar-invite(v-if='datesAsOptions()')
      .poll-common-calendar-invite__checkbox.poll-common-checkbox-option
        v-checkbox(v-model='outcome.calendarInvite' :label="$t('poll_common_calendar_invite.calendar_invite')")
      .poll-common-calendar-invite__form(v-if='outcome.calendarInvite')
        .poll-common-calendar-invite--pad-top
          v-select.lmo-flex__grow(v-model='outcome.pollOptionId' :items="options" item-value="id" item-text="value" :label="$t('poll_common_calendar_invite.poll_option_id')")
        .poll-common-calendar-invite--pad-top
          v-text-field.poll-common-calendar-invite__summary(type='text' :placeholder="$t('poll_common_calendar_invite.event_summary_placeholder')" v-model='outcome.customFields.event_summary' :label="$t('poll_common_calendar_invite.event_summary')")
          validation-errors(:subject='outcome', field='event_summary')
          v-text-field.poll-common-calendar-invite__location(type='text' :placeholder="$t('poll_common_calendar_invite.location_placeholder')" v-model='outcome.customFields.event_location' :label="$t('poll_common_calendar_invite.location')")
          //- v-textarea.md-input.poll-common-calendar-invite__description(type='text' :placeholder="$t('poll_common_calendar_invite.event_description_placeholder')" v-model='outcome.customFields.event_description' :label="$t('poll_common_calendar_invite.event_description')")

    .outcome-review-on
      v-menu(ref='menu' v-model='isShowingDatePicker' :close-on-content-click='false' offset-y min-width="290px")
        template(v-slot:activator='{ on, attrs }')
          v-text-field(clearable v-model='outcome.reviewOn' label="Review date" placeholder="2000-12-30" v-on='on' v-bind="attrs" prepend-icon="mdi-calendar")
        v-date-picker.outcome-review-on__datepicker(v-model='outcome.reviewOn' :min='dateToday' no-title @input="isShowingDatePicker = false")
      p(v-if="outcome.reviewOn" v-t="$t('poll_common_outcome_form.you_will_be_notified')")

    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='outcome' field='statement' :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
      template(v-slot:actions)
        v-btn.poll-common-outcome-form__submit(color="primary" @click='submit()' :loading="outcome.processing")
          span(v-t="'common.action.save'")
    validation-errors(:subject="outcome" field="statement")
</template>
