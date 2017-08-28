angular.module('loomioApp').directive 'notifyInput', (Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/input/notify_input.html'
  controller: ($scope) ->
    $scope.search = (query) ->
      Records.searchResults.fetchNotified(query)
