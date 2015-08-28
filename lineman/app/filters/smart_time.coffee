angular.module('loomioApp').filter 'smartTime', ->
  (time) ->
    time = moment(time)
    now = moment()

    sameDay = (time) ->
      time.year() == now.year() and
      time.month() == now.month() and
      time.date() == now.date()

    sameWeek = (time) ->
      time.year() == now.year() and
      time.month() == now.month() and
      time.week() == now.week()

    sameYear = (time) ->
      time.year() == now.year()

    format = switch
      when sameDay(time) then "h:mm a"
      when sameWeek(time) then "ddd"
      when sameYear(time) then "D MMM"
      else "MMM YYYY"

    time.format(format)
