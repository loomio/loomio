angular.module('loomioApp').config ($mdDateLocaleProvider) ->
  $mdDateLocaleProvider.formatDate = (date) ->
    moment(date).format('YYYY-M-D')
