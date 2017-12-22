angular.module('loomioApp').filter 'timeFromNowInWords', ->
  (date, excludeAgo) ->
    moment(date).fromNow(excludeAgo)
