angular.module('loomioApp').filter 'exactDateWithTime', ->
  (date) ->
    moment(date).format('dddd MMMM Do [at] h:mm a')
