angular.module('loomioApp').directive 'authEmailForm', ($translate, AppConfig, KeyEventService, AuthService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ($scope) ->
    $scope.email = $scope.user.email

    $scope.submit = ->
      return unless $scope.validateEmail()
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.emailStatus($scope.user).finally -> $scope.$emit 'doneProcessing'

    $scope.validateEmail = ->
      $scope.user.errors = {}
      if !$scope.email
        $scope.user.errors.email = [$translate.instant('auth_form.email_not_present')]
      else if !$scope.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.user.errors.email = [$translate.instant('auth_form.invalid_email')]
      !$scope.user.errors.email?

    KeyEventService.submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
