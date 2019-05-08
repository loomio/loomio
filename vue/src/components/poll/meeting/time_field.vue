<script lang="coffee">
import moment from 'moment'
import TimeService from '@/shared/services/time_service'
export default
  props:
    poll: Object
  data: ->
    dateToday: moment().format('YYYY-MM-DD')
    times: TimeService.timesOfDay()
    minDate: new Date()
</script>
<template lang="pug">
v-list-tile.poll-meeting-time-field(flex='true', layout='row')
  .poll-meeting-time-field__datepicker-container
    label.poll-common-closing-at-field__label(v-t="'poll_meeting_time_field.new_time_slot'")
    span {{ dateToday }}
    v-date-picker.lmo-flex.lmo-flex__baseline.poll-meeting-time-field__datepicker(v-model='poll.optionDate', :min='dateToday')
  .poll-meeting-time-field__timepicker-container(ng-if='poll.customFields.meeting_duration')
    v-select(v-model='poll.optionTime', :aria-label="$t('poll_meeting_time_field.closing_hour')" :items="times")
  .lmo-flex__grow
  .poll-meeting-time-field__add
    v-btn.poll-meeting-form__option-button.lmo-inline-action(ng-click='poll.addOption()', :aria-label="($t('poll_meeting_form.add_option_placeholder'))")
      v-icon.poll-meeting-form__option-icon mdi-plus
</template>
<style lang="scss">
</style>
