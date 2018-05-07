AppConfig = require 'shared/services/app_config'

module.exports = new class TimeService
  nameForZone: (zone, nameForLocal) ->
    if AppConfig.timeZone == zone
      nameForLocal
    else
      _.invert(AppConfig.timeZones)[zone]

  displayDay: (m, zone) =>
    m = moment(m) if typeof m is 'string'
    @inTimeZone(m, zone).format('ddd')

  displayDate: (m, zone) =>
    m = moment(m) if typeof m is 'string'
    @inTimeZone(m, zone).format("D MMMM#{@sameYear(m)}")

  displayTime: (m, zone) =>
    m = moment(m) if typeof m is 'string'
    return if @fullDayDate(m)
    @inTimeZone(m, zone).format('h:mma')

  displayDateAndTime: (m, zone) =>
    m = moment(m) if typeof m is 'string'
    _.compact([@displayDate(m, zone), @displayTime(m, zone)]).join(' ')

  fullDayDate: (m) ->
    m = moment(m) if typeof m is 'string'
    m._f == 'YYYY-MM-DD'

  isoDate: (m, zone) =>
    @inTimeZone(m, zone).toISOString()

  timesOfDay: ->
    times = []
    _.times 24, (hour) ->
      hour = (hour + 8) % 24
      hour = "0#{hour}" if hour < 10
      times.push moment("2015-01-01 #{hour}:00").format('h:mm a')
      times.push moment("2015-01-01 #{hour}:30").format('h:mm a')
    times


  inTimeZone: (m, zone) =>
    m.tz(zone || AppConfig.timeZone)

  sameYear: (date) ->
    if date.year() == moment().year() then "" else " YYYY"
