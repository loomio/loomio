TimeService = require 'shared/services/time_service'

module.exports =
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
  template:
    """
    <div class="poll-meeting-time">
      <span v-if="!sameYear(name)">{{ displayYear(name, zone) }}</span>
      <span>{{ displayDate(name, zone) }}</span>
      <span>{{ displayDay(name, zone) }}</span>
      <span v-if="!fullDayDate(name)">{{ displayTime(name, zone) }}</span>
    </div>
    """
