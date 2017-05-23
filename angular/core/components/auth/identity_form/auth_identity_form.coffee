angular.module('loomioApp').directive 'authIdentityForm', ($translate) ->
  scope: {user: '=', identity: '='}
  templateUrl: 'generated/components/auth/identity_form/auth_identity_form.html'
  controller: ($scope, AuthService, KeyEventService) ->
    $scope.createAccount = ->
      $scope.$emit 'processing'
      AuthService.confirmOauth().then (->), -> $scope.$emit 'doneProcessing'

    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.sendLoginLink($scope.user).then (->), ->
        $scope.user.errors = {email: [$translate.instant('auth_form.email_not_found')]}
      .finally ->
        $scope.$emit 'doneProcessing'

    KeyEventService.submitOnEnter $scope, anyEnter: true
