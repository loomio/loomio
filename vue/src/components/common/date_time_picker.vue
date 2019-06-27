<script lang="coffee">
import TimeService from '@/shared/services/time_service'
import Records     from '@/shared/services/records'
import { format, parse }  from 'date-fns'

export default
  props:
    value: Date
    min: Date
    dateLabel: Object
    timeLabel: Object

  created: ->
    @newValue = @value
    @dateStr = format(@value, 'yyyy-MM-dd')
    @timeStr = format(@value, 'h:mm a')
    @minStr  = format(@min, 'yyyy-MM-dd')

  data: ->
    dateStr: null
    timeStr: null
    dateMenu: false
    times: TimeService.meetingTimesOfDay()

  methods:
    updateNewValue: ->
      @newValue = parse("#{@dateStr} #{@timeStr}", 'yyyy-MM-dd h:mm a', new Date)
      console.log 'newValue', @newValue, "#{@dateStr} #{@timeStr}"
      @$emit('input', @newValue)

  watch:
    dateStr: -> @updateNewValue()
    timeStr: -> @updateNewValue()

</script>
<template lang="pug">
v-layout.date-time-picker
  v-menu(ref='dateTimePicker' v-model='dateMenu' offset-y full-width min-width='290px')
    template(v-slot:activator='{ on }')
      v-text-field.date-time-picker__date-field(v-model='dateStr' v-on='on' prepend-icon="mdi-calendar")
    v-date-picker.date-time-picker__date-picker(v-model='dateStr' no-title :min='minStr' @input="dateMenu = false")
  v-spacer
  v-combobox.date-time-picker__time-field(v-model="timeStr" :items="times" prepend-icon="mdi-clock-outline")
</template>
