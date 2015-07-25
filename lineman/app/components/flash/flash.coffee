angular.module('loomioApp').directive 'flash', ->
  restrict: 'E'
  templateUrl: 'generated/components/flash/flash.html'
  replace: true
  controllerAs: 'flash'
  controller: ($scope, $interval, FlashService) ->
    $scope.pendingDismiss = null

    $scope.$on 'flashMessage', (event, flash) =>
      $scope.flash = _.merge flash, { visible: true }
      $interval.cancel $scope.pendingDismiss if $scope.pendingDismiss?
      $scope.pendingDismiss = $interval($scope.dismiss, flash.duration, 1)

    $scope.$on 'dismissFlash', $scope.dismiss

    $scope.loading = -> $scope.flash.level == 'loading'
    $scope.display = -> $scope.flash.visible
    $scope.dismiss = -> $scope.flash.visible = false

    FlashService.success window.Loomio.flash.success if window.Loomio.flash.success?
    FlashService.info    window.Loomio.flash.notice  if window.Loomio.flash.notice?
    FlashService.warning window.Loomio.flash.warning if window.Loomio.flash.warning?
    FlashService.error   window.Loomio.flash.error   if window.Loomio.flash.error?

    return
