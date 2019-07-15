<script lang="coffee">
import Records     from '@/shared/services/records'
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import { map, sortBy, head } from 'lodash'
export default
  props:
    outcome: Object
  created: ->
    @options = map @outcome.poll().pollOptions(), (option) ->
      id:        option.id
      value:     exact(parseISO(option.name))
      attendees: option.stances().length

    @bestOption = head sortBy @options, (option) ->
      -1 * option.attendees # sort descending, so the best option is first

    @outcome.calendarInvite = true
    @outcome.pollOptionId = @outcome.pollOptionId or @bestOption.id
    @outcome.customFields.event_summary = @outcome.customFields.event_summary or @outcome.poll().title
  data: ->
    options: []
    bestOption: null
</script>
<template lang="pug">
.poll-common-calendar-invite.lmo-drop-animation
  .poll-common-calendar-invite__checkbox.poll-common-checkbox-option
    .poll-common-checkbox-option__text.md-list-item-text
      h3.lmo-h3(v-t="'poll_common_calendar_invite.calendar_invite'")
      p.md-caption(v-if='outcome.calendarInvite', v-t="'poll_common_calendar_invite.helptext_on'")
      p.md-caption(v-if='!outcome.calendarInvite', v-t="'poll_common_calendar_invite.helptext_off'")
    v-checkbox(v-model='outcome.calendarInvite')
  .poll-common-calendar-invite__form.animated(ng-show='outcome.calendarInvite')
    .md-block.poll-common-calendar-invite--pad-top
      label(v-t="'poll_common_calendar_invite.poll_option_id'")
      v-select.lmo-flex__grow(v-model='outcome.pollOptionId', :items="options", item-value="id", item-text="value")
        //- md-option(ng-repeat='option in options', ng-value='option.id') {{option.value}}
    .md-block.poll-common-calendar-invite--pad-top
      label(v-t="'poll_common_calendar_invite.event_summary'")
      v-text-field.poll-common-calendar-invite__summary(type='text', :placeholder="$t('poll_common_calendar_invite.event_summary_placeholder')", v-model='outcome.customFields.event_summary')
      validation-errors(:subject='outcome', field='event_summary')
    .md-block
      label(v-t="'poll_common_calendar_invite.location'")
      v-text-field.poll-common-calendar-invite__location(type='text', :placeholder="$t('poll_common_calendar_invite.location_placeholder')", v-model='outcome.customFields.event_location')
    .md-block
      label(v-t="'poll_common_calendar_invite.event_description'")
      v-textarea.md-input.lmo-primary-form-input.poll-common-calendar-invite__description(type='text', :placeholder="$t('poll_common_calendar_invite.event_description_placeholder')", v-model='outcome.customFields.event_description')
</template>
