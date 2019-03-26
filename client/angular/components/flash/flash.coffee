AppConfig    = require 'shared/services/app_config'
EventBus     = require 'shared/services/event_bus'
FlashService = require 'shared/services/flash_service'

angular.module('loomioApp').directive 'flash', ['$interval', ($interval) ->
  restrict: 'E'
  templateUrl: 'generated/components/flash/flash.html'
  replace: true
  controllerAs: 'flash'
  controller: ['$scope', ($scope) ->
    $scope.pendingDismiss = null

    EventBus.listen $scope, 'flashMessage', (event, flash) =>
      $scope.flash = _.merge flash, { visible: true }
      $scope.flash.message = $scope.flash.message or 'common.action.loading' if $scope.loading()
      $interval.cancel $scope.pendingDismiss if $scope.pendingDismiss?
      $scope.pendingDismiss = $interval($scope.dismiss, flash.duration, 1)

    EventBus.listen $scope, 'dismissFlash', $scope.dismiss

    $scope.loading = -> $scope.flash.level == 'loading'
    $scope.display = -> $scope.flash.visible
    $scope.dismiss = -> $scope.flash.visible = false

    $scope.ariaLive = ->
      if $scope.loading()
        'polite'
      else
        'assertive'

    return
  ]
]
