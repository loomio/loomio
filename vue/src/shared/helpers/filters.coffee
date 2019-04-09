export timeFromNowInWords = (date, excludeAgo) ->
  moment(date).fromNow(excludeAgo)

export exactDateWithTime = (date) ->
  moment(date).format('dddd MMMM Do [at] h:mm a')

export truncate = (string, length = 100, separator = ' ') ->
  _.truncate string, length: length, separator: separator
