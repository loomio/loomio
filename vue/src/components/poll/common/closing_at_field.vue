<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import TimeService from '@/shared/services/time_service'
import * as moment from 'moment'

# import { format} from 'date-fns'

export default
  props:
    poll: Object
  data: ->
    closingHour: moment(@poll.closingAt).format('h:mm a')
    closingDate: moment(@poll.closingAt).format('YYYY-MM-DD')
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
        v-menu(ref='menu' v-model='isShowingDatePicker' :close-on-content-click='false' offset-y)
          template(v-slot:activator='{ on }')
            v-text-field(v-model='closingDate' v-on='on' prepend-icon="mdi-calendar")
              template(v-slot:label)
                poll-common-closing-at(:poll="poll")
          v-date-picker.poll-common-closing-at-field__datepicker(v-model='closingDate' :min='dateToday' no-title @input="isShowingDatePicker = false")
      v-spacer
      v-combobox.poll-common-closing-at-field__timepicker(prepend-icon="mdi-clock-outline" v-model='closingHour' :label="$t('poll_meeting_time_field.closing_hour')" :items="times")
  validation-errors(:subject="poll", field="closingAt")
</template>
