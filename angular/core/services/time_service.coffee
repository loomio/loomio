angular.module('loomioApp').factory 'TimeService', (AppConfig) ->
  new class TimeService

    displayDate: (m, zone) =>
      if moment._f == 'YYYY-MM-DD'
        m.format("D MMMM#{@sameYear(m)}")
      else
        @inTimeZone(m, zone).format("D MMMM#{@sameYear(m)} - h:mma")

    isoDate: (m, zone) =>
      @inTimeZone(m, zone).toISOString()

    hasTime: (m) ->
      m._f != 'YYYY-MM-DD'

    inTimeZone: (m, zone) =>
      m.tz(zone || AppConfig.timeZone)

    sameYear: (date) ->
      if date.year() == moment().year() then "" else " YYYY"
