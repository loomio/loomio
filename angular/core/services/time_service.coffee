angular.module('loomioApp').factory 'TimeService', (AppConfig, $translate) ->
  new class TimeService
    nameForZone: (zone) ->
      if AppConfig.timeZone == zone
        $translate.instant 'common.local_time'
      else
        _.invert(AppConfig.timeZones)[zone]

    displayDate: (m, zone) =>
      if m._f == 'YYYY-MM-DD'
        m.format("D MMMM#{@sameYear(m)}")
      else
        @inTimeZone(m, zone).format("D MMMM#{@sameYear(m)} - h:mma")

    isoDate: (m, zone) =>
      @inTimeZone(m, zone).toISOString()

    inTimeZone: (m, zone) =>
      m.tz(zone || AppConfig.timeZone)

    sameYear: (date) ->
      if date.year() == moment().year() then "" else " YYYY"
