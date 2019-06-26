<style lang="scss">
// .poll-common-closing-at-field {
//   margin: 16px 0;
// }
//
// .poll-common-closing-at-field__label {
//   overflow: visible !important;
//   color: rgba(0,0,0,0.38) !important;
// }
//
// .poll-common-closing-at-field {
//   display: flex;
//   flex-direction: column;
// }
//
// .poll-common-closing-at-field__zone {
//   color: rgba(0,0,0,0.38);
//   margin: -40px 0 0 0;
// }
//
// .poll-common-closing-at-field__inputs {
//   display: flex;
// }
</style>

<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import _times from 'lodash/times'
import TimeService from '@/shared/services/time_service'
import moment from 'moment'

export default
  props:
    poll: Object
  data: ->
    closingHour: moment().startOf('hour').format('h:mm a')
    closingDate: moment(@poll.closingAt.toDate()).format('YYYY-MM-DD')
    dateToday: moment().format('YYYY-MM-DD')
    times: TimeService.timesOfDay()
    timeZone: AppConfig.timeZone
    isShowingDatePicker: false
  methods:
    updateClosingAt: ->
      @poll.closingAt = moment(@closingDate).startOf('day').add(@closingHour, 'hours')
    allowedMinutes: (m) ->
      m % 15 == 0
  watch:
    closingDate: (val) ->
      @updateClosingAt()
    closingHour: (val) ->
      @updateClosingAt()
</script>

<template lang="pug">
.poll-common-closing-at-field.my-3
  .poll-common-closing-at-field__inputs
    v-layout(wrap)
      v-flex
        v-menu(ref='menu' v-model='isShowingDatePicker' :close-on-content-click='false' :nudge-right='40' transition='scale-transition' offset-y full-width min-width='290px')
          template(v-slot:activator='{ on }')
            v-text-field(v-model='closingDate' readonly v-on='on' prepend-icon="mdi-calendar")
              template(v-slot:label)
                poll-common-closing-at(:poll="poll")
          v-date-picker.poll-common-closing-at-field__datepicker(v-model='closingDate' :min='dateToday' @input="isShowingDatePicker = false")
      v-spacer
      v-combobox.poll-common-closing-at-field__timepicker(prepend-icon="mdi-clock-outline" v-model='closingHour' :label="$t('poll_meeting_time_field.closing_hour')" :items="times")
  validation-errors(:subject="poll", field="closingAt")
</template>
