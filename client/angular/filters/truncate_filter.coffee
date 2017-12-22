angular.module('loomioApp').filter 'truncate', ->
  (string, length = 100, separator = ' ') ->
    _.trunc string, length: length, separator: separator
