<script lang="coffee">
import Records     from '@/shared/services/records'
import { times } from 'lodash-es'
import { hoursOfDay } from '@/shared/helpers/format_time'
import { format, parse, isValid } from 'date-fns'

export default
  props:
    value: Date
    min: Date
    dateLabel: Object
    timeLabel: Object

  created: ->
    @newValue = @value
    @dateStr = format(@value, 'yyyy-MM-dd')
    @timeStr = format(@value, 'HH:mm')
    @minStr  = format(@min, 'yyyy-MM-dd')

  data: ->
    dateStr: null
    timeStr: null
    dateMenu: false
    times: hoursOfDay
    validDate: (val) =>
      isValid(parse(val, "yyyy-MM-dd", new Date()))


  methods:
    updateNewValue: ->
      return unless isValid(parse("#{@dateStr} #{@timeStr}", 'yyyy-MM-dd HH:mm', new Date))
      @newValue = parse("#{@dateStr} #{@timeStr}", 'yyyy-MM-dd HH:mm', new Date)
      @$emit('input', @newValue)

  watch:
    dateStr: -> @updateNewValue()
    timeStr: -> @updateNewValue()

</script>
<template lang="pug">
v-layout.date-time-picker
  v-menu(ref='dateTimePicker' v-model='dateMenu' offset-y min-width='290px')
    template(v-slot:activator='{ on }')
      v-text-field.date-time-picker__date-field(v-model='dateStr' v-on='on' placeholder="2000-12-31" :rules="[validDate]" prepend-icon="mdi-calendar")
    v-date-picker.date-time-picker__date-picker(v-model='dateStr' no-title :min='minStr' @input="dateMenu = false")
  v-spacer
  v-combobox.date-time-picker__time-field(v-model="timeStr" :items="times" prepend-icon="mdi-clock-outline")
</template>
