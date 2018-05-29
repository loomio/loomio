TimeService = require('shared/services/time_service')

module.exports =
  class MeetingPollOptionState

    constructor: (option_names) ->
      @mode = "dateOnly"
      @resetModel()
      @parsePollOptions(option_names)

    resetIndicies: =>
      @dates = _.keys(@model)
      @daydates = _.map @dates, dateToDayDate
      @datemoments = _.map @dates, moment
      @datecount = @dates.length

    resetModel: =>
      @model = {}
      @resetIndicies()

    dateOnlyMode: =>
      @mode = "dateOnly"

    collapsedMode: =>
      @mode = "collapsed"

    expandedMode: =>
      @mode = "expanded"

    #called by the calendar
    toggleCalendarDate: (m) =>
      date = momentToDate(m)
      if date in @model
        delete @model[date]
      else
        @model[date] = null
      @resetIndicies()

    addTimesToDate: (time, date) =>
      @model[date] = times
      @resetIndicies()

    addTimesToAll: (times) =>
      @model = _.mapValues(@model, -> times)
      @resetIndicies()

    parsePollOptions: (pollOptions) =>
      _.map(pollOptions, (name) =>
        m = moment(name)
        date = momentToDate(m)
        time = momentToTime(m)
        @model[date] = @model[date] || []
        @model[date].push(time)
      )

    getPollOptionNames: () =>
      switch @mode
        when "dateOnly" then @dates
        when "expanded", "collapsed"
          _.flatten _.map(_.toPairs(@model), ([date, times])->
            _.map times, (time) ->
              composeDateTime(date, time)
          )

momentToTime = (m) ->
  hour = m.hour()
  adjhour = if hour > 12 then hour - 12 else hour
  ampm = if hour > 12 then 'pm' else 'am'
  {hour: ""+adjhour, minute:""+m.minute(), ampm}

momentToDate = (m) ->
  m.format("YYYY-MM-DD")

dayDateToDate = (daydate) ->
  momentToDate(moment(daydate))

dateToDayDate = (date) ->
  TimeService.displayDayDate(date)

composeDateTime = (date, time) ->
  hour = if time.ampm == 'pm' then parseInt(time.hour)+12 else parseInt(time.hour)
  date = moment(date)
  date.set({'hour': hour, 'minute':parseInt(time.minute)})
  date.toIsoString()
