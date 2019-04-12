<style lang="scss">
</style>

<script lang="coffee">
import TimeService from '@/shared/services/time_service'

export default
  props:
    name: String
    zone: Object
  data: ->
    sameYear    : TimeService.sameYear
    displayYear : TimeService.displayYear
    displayDay  : TimeService.displayDay
    displayDate : TimeService.displayDate
    displayTime : TimeService.displayTime
    fullDayDate : TimeService.fullDayDate
</script>

<template>
    <div class="poll-meeting-time">
      <span v-if="!sameYear(name)">{{ displayYear(name, zone) }}</span>
      <span>{{ displayDate(name, zone) }}</span>
      <span>{{ displayDay(name, zone) }}</span>
      <span v-if="!fullDayDate(name)">{{ displayTime(name, zone) }}</span>
    </div>
</template>
