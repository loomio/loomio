angular.module('loomioApp').directive 'authForm', (AppConfig, Records, AuthService) ->
  scope: {preventClose: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ($scope) ->
    $scope.user = AuthService.applyEmailStatus Records.users.build(), AppConfig.pendingIdentity

    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    $scope.pendingIdentity = AppConfig.pendingIdentity

    $scope.$on 'processing',     -> $scope.isDisabled = true
    $scope.$on 'doneProcessing', -> $scope.isDisabled = false
