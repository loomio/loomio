angular.module('loomioApp').filter 'timeFromNowInWords', ->
  (date, excludeAgo) ->
    moment(date).fromNow(excludeAgo)

angular.module('loomioApp').filter 'exactDateWithTime', ->
  (date) ->
    moment(date).format('dddd MMMM Do [at] h:mm a')

angular.module('loomioApp').filter 'withinRange', ->
  (models, dateField, range) ->
    today = moment().startOf('day')
    _.filter models, (model) ->
      date = moment(model[dateField])
      todayClone = today.clone()
      switch range
        when 'today'      then date.isAfter   today
        when 'yesterday'  then date.isBetween today.clone().subtract(1, 'day'),   today.clone()
        when 'thisWeek'   then date.isBetween today.clone().subtract(1, 'week'),  today.clone().subtract(1, 'day')
        when 'thisMonth'  then date.isBetween today.clone().subtract(1, 'month'), today.clone().subtract(1, 'week')
        when 'older'      then date.isBefore  today.subtract(1, 'month')
