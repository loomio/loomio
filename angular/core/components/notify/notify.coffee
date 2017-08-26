angular.module('loomioApp').directive 'notify', (Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/notify.html'
  controller: ($scope) ->

    $scope.search = (query) ->
      Records.searchResults.fetchNotified(query)
