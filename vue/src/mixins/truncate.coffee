import {truncate} from 'lodash-es'
export default
  methods:
    truncate: (string, length = 100, separator = ' ') ->
      truncate string, length: length, separator: separator
