module.exports =
  timeFromNowInWords: (date, excludeAgo) ->
    moment(date).fromNow(excludeAgo)

  exactDateWithTime: (date) ->
    moment(date).format('dddd MMMM Do [at] h:mm a')

  truncate: (string, length = 100, separator = ' ') ->
    _.truncate string, length: length, separator: separator
