angular.module('loomioApp').config ['$mdDateLocaleProvider', ($mdDateLocaleProvider) ->
  $mdDateLocaleProvider.formatDate = (date) ->
    moment(date).format('D MMMM YYYY')
]
