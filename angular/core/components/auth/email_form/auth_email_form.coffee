angular.module('loomioApp').directive 'authEmailForm', ($translate, AppConfig, KeyEventService, AuthService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ($scope) ->
    $scope.submit = ->
      return unless $scope.validateEmail()
      $scope.$emit 'processing'
      $scope.user.email = $scope.email
      AuthService.emailStatus($scope.user).then (data) ->
        keys = ['avatar_kind', 'avatar_initials', 'gravatar_md5', 'avatar_url', 'has_password', 'email_status']
        $scope.user.update _.mapKeys _.pick(data, keys), (v,k) -> _.camelCase(k)
      .finally ->
        $scope.$emit 'doneProcessing'

    $scope.validateEmail = ->
      $scope.user.errors = {}
      if !$scope.email
        $scope.user.errors.email = [$translate.instant('auth_form.email_not_present')]
      else if !$scope.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.user.errors.email = [$translate.instant('auth_form.invalid_email')]
      !$scope.user.errors.email?

    KeyEventService.submitOnEnter($scope, anyEnter: true)
    $scope.$emit 'focus'
