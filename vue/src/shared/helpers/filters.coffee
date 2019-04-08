export function timeFromNowInWords = (date, excludeAgo) ->
  moment(date).fromNow(excludeAgo)

export function exactDateWithTime = (date) ->
  moment(date).format('dddd MMMM Do [at] h:mm a')

export function truncate = (string, length = 100, separator = ' ') ->
  _.truncate string, length: length, separator: separator
