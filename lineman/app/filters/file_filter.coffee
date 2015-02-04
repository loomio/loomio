angular.module('loomioApp').filter 'fileSize', ->
  (bytes) ->
    if isNaN(bytes) then return "(invalid file size)"

    if bytes < 1024
      denom = "bytes"
      filesize = bytes
    else if bytes < Math.pow(1024, 2)
      denom = "kB"
      filesize = bytes / 1024
    else if bytes < Math.pow(1024, 3)
      denom = "MB"
      filesize = bytes / Math.pow(1024, 2)
    else
      denom = "GB"
      filesize = bytes / Math.pow(1024, 3)

    "(#{filesize.toFixed(1)} #{denom})"

angular.module('loomioApp').filter 'exactDateWithTime', ->
  (date) ->
    moment(date).format('dddd MMMM Do [at] h:mm a')
