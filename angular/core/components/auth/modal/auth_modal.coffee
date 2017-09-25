angular.module('loomioApp').factory 'AuthModal', (AuthService, Records, AppConfig) ->
  templateUrl: 'generated/components/auth/modal/auth_modal.html'
  controller: ($scope, preventClose) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.user = AuthService.applyEmailStatus Records.users.build(), AppConfig.pendingIdentity
    $scope.preventClose = preventClose
    $scope.$on 'signedIn', $scope.$close

    $scope.back = -> $scope.user.emailStatus = null

    $scope.showBackButton = ->
      $scope.user.emailStatus and
      !$scope.user.sentLoginLink and
      !$scope.user.sentPasswordLink
