angular.module('loomioApp').directive 'pinToggle', (AbilityService) ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/pin_toggle/pin_toggle.html'
  replace: true
  controller: ($scope) ->
    $scope.show = ->
      $scope.thread.pinned or
      AbilityService.canPinThread($scope.thread)

    $scope.savePin = ->
      if AbilityService.canPinThread($scope.thread)
        $scope.thread.savePin()
      else
        $scope.thread.saveReaderPin()
