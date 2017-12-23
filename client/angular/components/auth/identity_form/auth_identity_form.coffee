AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').directive 'authIdentityForm', ($window, $translate) ->
  scope: {user: '=', identity: '='}
  templateUrl: 'generated/components/auth/identity_form/auth_identity_form.html'
  controller: ($scope, AuthService, KeyEventService) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.createAccount = ->
      $scope.$emit 'processing'
      AuthService.confirmOauth().then ->
        $window.location.reload()
      , ->
        $scope.$emit 'doneProcessing'

    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.sendLoginLink($scope.user).then (->), ->
        $scope.user.errors = {email: [$translate.instant('auth_form.email_not_found')]}
      .finally ->
        $scope.$emit 'doneProcessing'

    KeyEventService.submitOnEnter $scope, anyEnter: true
