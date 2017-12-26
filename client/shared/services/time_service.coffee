AppConfig = require 'shared/services/app_config.coffee'
moment    = require 'moment'

_ = require 'lodash'

module.exports = new class TimeService
  nameForZone: (zone, nameForLocal) ->
    if AppConfig.timeZone == zone
      nameForLocal
    else
      _.invert(AppConfig.timeZones)[zone]

  displayDate: (m, zone) =>
    m = moment(m) if typeof m is 'string'
    if m._f == 'YYYY-MM-DD'
      m.format("D MMMM#{@sameYear(m)}")
    else
      @inTimeZone(m, zone).format("D MMMM#{@sameYear(m)} - h:mma")

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
