<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { format, formatDistance, parse } from 'date-fns'
import { hoursOfDay, exact} from '@/shared/helpers/format_time'

export default
  props:
    poll: Object

  data: ->
    closingHour: format(@poll.closingAt, 'h:mm a')
    closingDate: format(@poll.closingAt, 'yyyy-MM-dd')
    dateToday: format(new Date, 'yyyy-MM-dd')
    times: hoursOfDay
    timeZone: AppConfig.timeZone
    isShowingDatePicker: false

  methods:
    exact: exact
    updateClosingAt: ->
      @poll.closingAt = parse("#{@closingDate} #{@closingHour}", "yyyy-MM-dd h:mm a", new Date())

  computed:
    label: ->
      formatDistance(@poll.closingAt, new Date, {addSuffix: true})
  watch:
    closingDate: (val) -> @updateClosingAt()
    closingHour: (val) -> @updateClosingAt()
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
                span(v-t="{ path: 'common.closing_in', args: { time: label } }" :title="exact(poll.closingAt)")
          v-date-picker.poll-common-closing-at-field__datepicker(v-model='closingDate' :min='dateToday' no-title @input="isShowingDatePicker = false")
      v-spacer
      v-combobox.poll-common-closing-at-field__timepicker(prepend-icon="mdi-clock-outline" v-model='closingHour' :label="$t('poll_meeting_time_field.closing_hour')" :items="times")
  validation-errors(:subject="poll", field="closingAt")
</template>
