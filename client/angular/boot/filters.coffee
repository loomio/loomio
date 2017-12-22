angular.module('loomioApp').filter 'truncate', ->
  (string, length = 100, separator = ' ') ->
    _.trunc string, length: length, separator: separator

angular.module('loomioApp').filter 'timeFromNowInWords', ->
  (date, excludeAgo) ->
    moment(date).fromNow(excludeAgo)

angular.module('loomioApp').filter 'exactDateWithTime', ->
  (date) ->
    moment(date).format('dddd MMMM Do [at] h:mm a')
