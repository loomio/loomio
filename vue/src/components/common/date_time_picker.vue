<script lang="coffee">
import Records     from '@/shared/services/records'
import { times } from 'lodash'
import { hoursOfDay, timeFormat } from '@/shared/helpers/format_time'
import { format, parse, isValid } from 'date-fns'

export default
  props:
    value: Date
    min: Date
    dateLabel: Object
    timeLabel: Object

  created: ->
    @newValue = @value

  data: ->
    dateStr: @value && format(@value, 'yyyy-MM-dd') || ''
    timeStr: @value && format(@value, timeFormat()) || ''
    minStr:  @value && format(@min, 'yyyy-MM-dd') || ''
    dateMenu: false
    times: hoursOfDay()
    placeholder: format(new Date(), 'yyyy-MM-dd')
    validDate: (val) =>
      isValid(parse(val, "yyyy-MM-dd", new Date()))

  methods:
    updateNewValue: ->
      val = parse("#{@dateStr} #{@timeStr}", "yyyy-MM-dd #{timeFormat()}", new Date)
      return unless isValid(val)
      @newValue = val
      @$emit('input', @newValue)

  watch:
    dateStr: -> @updateNewValue()
    timeStr: -> @updateNewValue()

</script>
<template lang="pug">
v-layout.date-time-picker
  v-menu(ref='dateTimePicker' v-model='dateMenu' offset-y min-width='290px')
    template(v-slot:activator='{ on, attrs }')
      v-text-field.date-time-picker__date-field(
        v-model='dateStr'
        v-on='on'
        v-bind='attrs'
        :placeholder="placeholder"
        :rules="[validDate]"
        prepend-icon="mdi-calendar")
    v-date-picker.date-time-picker__date-picker(
      v-model='dateStr'
      no-title
      :min='minStr'
      @input="dateMenu = false")
  v-spacer
  v-combobox.date-time-picker__time-field(
    v-model="timeStr"
    :items="times"
    prepend-icon="mdi-clock-outline")
</template>
