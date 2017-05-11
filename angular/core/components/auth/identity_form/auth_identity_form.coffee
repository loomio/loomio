angular.module('loomioApp').directive 'authIdentityForm', ->
  scope: {user: '=', identity: '='}
  templateUrl: 'generated/components/auth/identity_form/auth_identity_form.html'
  controller: ($scope, AuthService) ->
    $scope.createAccount = ->
      $scope.$emit 'processing'
      AuthService.confirmOauth().then (->), -> $scope.$emit 'doneProcessing'

    $scope.linkAccounts = ->
      $scope.$emit 'processing'
      AuthService.sendLoginLink($scope.user).finally -> $scope.$emit 'doneProcessing'
