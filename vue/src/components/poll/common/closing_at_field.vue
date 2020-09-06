<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { format, formatDistance, parse, startOfHour, isValid, addDays } from 'date-fns'
import { hoursOfDay, exact} from '@/shared/helpers/format_time'

export default
  props:
    poll: Object

  data: ->
    closingHour: format(startOfHour(@poll.closingAt || new Date()), 'HH:mm')
    closingDate: format(@poll.closingAt || new Date(), 'yyyy-MM-dd')
    dateToday: format(new Date, 'yyyy-MM-dd')
    times: hoursOfDay
    timeZone: AppConfig.timeZone
    isShowingDatePicker: false
    validDate: => isValid(parse("#{@closingDate} #{@closingHour}", "yyyy-MM-dd HH:mm", new Date()))

  methods:
    exact: exact
    updateClosingAt: ->
      date = parse("#{@closingDate} #{@closingHour}", "yyyy-MM-dd HH:mm", new Date())
      if isValid(date)
        @poll.closingAt = date

  computed:
    label: ->
      return false unless @poll.closingAt
      formatDistance(@poll.closingAt, new Date, {addSuffix: true})

  watch:
    'poll.closingAt': (val) ->
      return unless val
      @closingHour = format(startOfHour(val), 'HH:mm')
      @closingDate = format(val, 'yyyy-MM-dd')

    closingDate: (val) ->
      @updateClosingAt()

    closingHour: (val) -> @updateClosingAt()
</script>

<template lang="pug">
div
  .poll-common-closing-at-field.my-3
    .poll-common-closing-at-field__inputs
      v-layout(wrap)
        v-flex
          v-menu(ref='menu' v-model='isShowingDatePicker' :close-on-content-click='false' offset-y )
            template(v-slot:activator='{ on, attrs }')
              v-text-field(:disabled="!poll.closingAt" v-model='closingDate' :rules="[validDate]" placeholder="2000-12-30" v-on='on' v-bind="attrs" prepend-icon="mdi-calendar")
                template(v-slot:label)
                  span(v-if="poll.closingAt" v-t="{ path: 'common.closing_in', args: { time: label } }" :title="exact(poll.closingAt)")
                  span(v-if="!poll.closingAt" v-t="'poll_common_closing_at_field.no_closing_date'")
            v-date-picker.poll-common-closing-at-field__datepicker(:disabled="!poll.closingAt" v-model='closingDate' :min='dateToday' no-title @input="isShowingDatePicker = false")
        v-spacer
        v-select.poll-common-closing-at-field__timepicker(:disabled="!poll.closingAt" prepend-icon="mdi-clock-outline" v-model='closingHour' :label="$t('poll_meeting_time_field.closing_hour')" :items="times")
    validation-errors(:subject="poll", field="closingAt")
    p.caption(v-if="poll.closingAt" v-t="'poll_common_form.reminder_note'")

</template>
