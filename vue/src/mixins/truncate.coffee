export default
  methods:
    truncate: (string, length = 100, separator = ' ') ->
      _.truncate string, length: length, separator: separator
