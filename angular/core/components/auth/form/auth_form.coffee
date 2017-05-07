angular.module('loomioApp').directive 'authForm', (AppConfig, Records) ->
  scope: {preventClose: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ($scope) ->
    $scope.user = Records.users.build(AppConfig.pendingIdentity)

    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    $scope.$on 'processing',     -> $scope.isDisabled = true
    $scope.$on 'doneProcessing', -> $scope.isDisabled = false
