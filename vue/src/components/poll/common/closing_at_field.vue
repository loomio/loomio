<style lang="scss">
.poll-common-closing-at-field {
  margin: 16px 0;
}

.poll-common-closing-at-field__label {
  overflow: visible !important;
  color: rgba(0,0,0,0.38) !important;
}

.poll-common-closing-at-field {
  display: flex;
  flex-direction: column;
}

.poll-common-closing-at-field__zone {
  color: rgba(0,0,0,0.38);
  margin: -40px 0 0 0;
}

.poll-common-closing-at-field__inputs {
  display: flex;
}
</style>

<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import _times from 'lodash/times'

export default
  props:
    poll: Object
  data: ->
    closingHour: @poll.closingAt.format('H')
    closingDate: @poll.closingAt.toDate()
    minDate: new Date().toString()
    hours: _times 24, (i) ->

    times: _times 24, (i) ->
      i = "0#{i}" if i < 10
      moment("2015-01-01 #{i}:00").format('h a')
    dateToday: moment().format('YYYY-MM-DD')
    timeZone: AppConfig.timeZone
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
.poll-common-closing-at-field
  .poll-common-closing-at-field__inputs
    .md-no-errors
      label.poll-common-closing-at-field__label
        poll-common-closing-at(:poll="poll")
      //- v-date-picker(v-model="closingDate", :min="minDate", md-hide-icons="calendar")
    .md-input-container
      //- v-time-picker(v-model="closingHour" :allowed-minutes="allowedMinutes")
      //- v-select(v-model="closingHour", :items="hours")
        //- md-option(ng-repeat="hour in hours", ng-value: "hour", @change="hour == closingHour")
          {{ times[hour] }}
  validation-errors(:subject="poll", field="closingAt")
</template>
