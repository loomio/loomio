{
  timeFromNowInWords,
  exactDateWithTime,
  truncate
} = require 'shared/helpers/filters.coffee'

angular.module('loomioApp').filter 'timeFromNowInWords', -> timeFromNowInWords
angular.module('loomioApp').filter 'exactDateWithTime',  -> exactDateWithTime
angular.module('loomioApp').filter 'truncate',           -> truncate
