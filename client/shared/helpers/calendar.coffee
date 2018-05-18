moment = require 'moment'

module.exports =
  calendarMonth: (today = moment()) ->
    first      = today.clone().date(1)
    last       = first.clone().add(1, 'month').day(7)
    current    = first.clone().day(0)

    weeks     = []
    weekIndex = 0
    while current.isBefore(last)
      if current.day() == 0
        weekIndex += 1
        weeks[weekIndex] = []

      weeks[weekIndex].push(current)
      current = current.clone().add(1, 'day')
    weeks

  calendarStyle: (day, today, current, selected) ->
    if _.contains(selected, day)
      { 'background-color': 'accent-300'}
    else
      {}
