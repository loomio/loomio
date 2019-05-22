<style lang="scss">
</style>

<script lang="coffee">
import TimeService from '@/shared/services/time_service'

export default
  props:
    name: String
    zone: String
  data: ->
    sameYear    : TimeService.sameYear
    displayYear : TimeService.displayYear
    displayDay  : TimeService.displayDay
    displayDate : TimeService.displayDate
    displayTime : TimeService.displayTime
    fullDayDate : TimeService.fullDayDate
</script>

<template lang="pug">
.poll-meeting-time
  span(v-if='!sameYear(name)') {{ displayYear(name, zone) }}
  span {{ displayDate(name, zone) }}
  span {{ displayDay(name, zone) }}
  span(v-if='!fullDayDate(name)') {{ displayTime(name, zone) }}
</template>
