moment = require 'moment'

parseTime12 = (text) ->
  #return possible interpretations
  match12 = text.match(/^(1[0-2]|\d):?(\d{1,2})?(a.?|p.?)?$/)

  if (match12)
    [xx, hour, minute, meridian] = match12
    return {hour, minute, ampm: meridian}


parseTime24 =  (text) ->
  match24 = text.match(/^([01]\d)(\d{1,2})?$/)

  if (match24)
    [xx, hour, minute] = match24
    hourNum = Number.parseInt(hour)
    hour = if (hourNum > 12) then String(hourNum - 12) else hour
    ampm = if (hourNum > 12) then 'pm' else 'am'

    return {hour, minute, ampm}

searchDayTimes = (search_time, times) ->
  times.filter( (target_time) ->
    # the list time matches
    search_time.hour == target_time.hour && \
    (search_time.minute == undefined || search_time.minute[0] == target_time.minute[0])&& \
    (search_time.ampm == undefined || search_time.ampm[0] == target_time.ampm[0] )
  )

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
    hours = _.range(1, 13).map(String)
    minutes = _.range(timeperhour).map (i)-> String(i*increment)
    times = []

    for ampm in ['am','pm']
      for hour in hours
        for minute in minutes
          times.push({hour, minute, ampm})

    times

  selectDayTimes: (times, searchText) ->
    # with preference to 12 hour show 24 hour times where the 12 shows nothing

    time12 = parseTime12(searchText)
    time24 = parseTime24(searchText)

    if time12
      times = searchDayTimes(time12, times)
      if times.length != 0
        return times

    if time24
      searchDayTimes(time24, times)
    else
      []
