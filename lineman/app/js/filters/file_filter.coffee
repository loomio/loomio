angular.module('loomioApp').filter 'fileSize', ->
  (filesize) ->
    "#{Math.floor(filesize / 1000)} kb" 

angular.module('loomioApp').filter 'exactDateWithTime', ->
  (date) ->
    moment(date).format('dddd MMMM Do [at] h:mm a')
