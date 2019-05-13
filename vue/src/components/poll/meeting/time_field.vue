<script lang="coffee">
import moment from 'moment'
import TimeService from '@/shared/services/time_service'
export default
  props:
    poll: Object
  created: ->
    @poll.optionDate = moment().format('YYYY-MM-DD')
  data: ->
    dateToday: moment().format('YYYY-MM-DD')
    times: TimeService.timesOfDay()
    isShowingDatePicker: false
  methods:
    closeDatePicker: ->
      @isShowingDatePicker = false

</script>
<template lang="pug">
v-list-tile.poll-meeting-time-field(flex='true', layout='row')
  .poll-meeting-time-field__datepicker-container
    v-menu(ref='menu', v-model='isShowingDatePicker', :close-on-content-click='false', :nudge-right='40', :return-value.sync='poll.optionDate', lazy='', transition='scale-transition', offset-y='', full-width='', min-width='290px')
      template(v-slot:activator='{ on }')
        v-text-field(v-model='poll.optionDate', :label="$t('poll_meeting_time_field.new_time_slot')", readonly='', v-on='on')
      v-date-picker.poll-meeting-time-field__datepicker(v-model='poll.optionDate', no-title='', scrollable='', :min='dateToday')
        v-spacer
          v-btn(flat='', color='primary', @click='isShowingDatePicker = false') Cancel
          v-btn(flat='', color='primary', @click='$refs.menu.save(poll.optionDate)') OK

  .poll-meeting-time-field__timepicker-container(ng-if='poll.customFields.meeting_duration')
    v-select(v-model='poll.optionTime', :label="$t('poll_meeting_time_field.closing_hour')" :items="times")
  .lmo-flex__grow
  .poll-meeting-time-field__add
    v-btn.poll-meeting-form__option-button.lmo-inline-action(@click='poll.addOption()', :aria-label="($t('poll_meeting_form.add_option_placeholder'))")
      v-icon.poll-meeting-form__option-icon mdi-plus
</template>
<style lang="scss">
</style>
