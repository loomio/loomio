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

  generateDayTimes: (increment) ->
    timeperhour = Math.floor(60 / increment)
    hours = _.range(1, 13)
    minutes = _.range(timeperhour).map (i)-> i*increment
    times = []

    for ampm in ['am','pm']
      for hour in hours
        for minute in minutes
          zero = if minute < 10 then '0' else ''
          times.push("#{hour}:#{zero}#{minute}#{ampm}")

    times

  searchDayTimes: (search_exp, times) ->
    times.filter( (item) ->
      # the item contains the text of the search expression
      item[0] == search_exp[0]
    )
