angular.module('loomioApp').directive 'notifyChip', ->
  scope: {chip: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/chip/notify_chip.html'
  controller: ($scope) ->
    $scope.editChip = ->
      "Editing chip with title #{$scope.chip.title}..."
