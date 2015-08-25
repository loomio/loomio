angular.module('loomioApp').directive 'flash', (AppConfig) ->
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

    FlashService.success AppConfig.flash.success if AppConfig.flash.success?
    FlashService.info    AppConfig.flash.notice  if AppConfig.flash.notice?
    FlashService.warning AppConfig.flash.warning if AppConfig.flash.warning?
    FlashService.error   AppConfig.flash.error   if AppConfig.flash.error?

    return
