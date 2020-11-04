<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import Flash from '@/shared/services/flash'
import EventBus from '@/shared/services/event_bus'
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'

import Vue     from 'vue'
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import { uniq, map, sortBy, head, find, filter, sum } from 'lodash'
import { onError } from '@/shared/helpers/form'

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

  mounted: ->
    @fetchMemberships()
    @watchRecords
      collections: ['groups', 'memberships']
      query: (records) => @updateSuggestions()

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

  computed:
    model: -> @outcome
    audiences: ->
      ret = []
      if @recipients.length == 0
        if @outcome.group()
          ret.push
            id: 'group'
            name: @outcome.group().name
            size: @outcome.group().acceptedMembershipsCount
        if @outcome.poll().discussionId
          ret.push
            id: 'discussion_group'
            name: @$t('announcement.audiences.discussion_group')
            size: @outcome.poll().discussion().membersCount
        if @outcome.poll().stancesCount > 1
          ret.push
            id: 'voters'
            name: @$t('announcement.audiences.voters', pollType: @outcome.poll().translatedPollType())
            size: @outcome.poll().stancesCount
        if @outcome.poll().participantsCount > 1
          ret.push
            id: 'participants'
            name: @$t('announcement.audiences.participants')
            size: @outcome.poll().participantsCount

      ret.filter (a) => a.name.match(new RegExp(@query, 'i'))

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
    //- p outcome.pollId {{outcome.pollId}}
    //- p audience: {{outcome.recipientAudience}}
    //- p userIds: {{outcome.recipientUserIds}}
    //- p userEmails: {{outcome.recipientEmails}}
    //- p audiences: {{audiences}}
    //- p {{recipients.length}}
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

    lmo-textarea.poll-common-outcome-form__statement.lmo-primary-form-input(:model='outcome' field='statement' :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
      template(v-slot:actions)
        v-btn.poll-common-outcome-form__submit(color="primary" @click='submit()' v-t="'common.action.save'")
    validation-errors(:subject="outcome" field="statement")
</template>
