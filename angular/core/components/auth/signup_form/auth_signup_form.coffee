angular.module('loomioApp').directive 'authSignupForm', ($translate, AppConfig, AuthService, KeyEventService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/signup_form/auth_signup_form.html'
  controller: ($scope) ->
    $scope.vars         = {}
    $scope.recaptchaKey = AppConfig.recaptchaKey
    $scope.name         = $scope.user.name
    $scope.allow        = ->
      AppConfig.features.create_user or AppConfig.pendingIdentity

    $scope.submit = ->
      if $scope.vars.name
        $scope.user.errors = {}
        $scope.$emit 'processing'
        $scope.user.name  = $scope.vars.name
        AuthService.signUp($scope.user).finally -> $scope.$emit 'doneProcessing'
      else
        $scope.user.errors =
          name: [$translate.instant('auth_form.name_required')]

    KeyEventService.submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
