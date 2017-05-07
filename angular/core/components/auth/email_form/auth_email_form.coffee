angular.module('loomioApp').directive 'authEmailForm', ($location, Records, KeyEventService, AuthService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ($scope) ->
    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.emailStatus($scope.user).finally -> $scope.$emit 'doneProcessing'

    document.querySelector('.auth-email-form__email input').focus()

    KeyEventService.submitOnEnter($scope, anyEnter: true)
