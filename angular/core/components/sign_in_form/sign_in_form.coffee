angular.module('loomioApp').factory 'SignInForm', ->
  templateUrl: 'generated/components/sign_in_form/sign_in_form.html'
  controller: ($scope, $location, $window, preventClose, KeyEventService, Session, AppConfig, Records, FormService) ->
    $scope.session = Records.sessions.build(type: 'password', rememberMe: true)
    $scope.preventClose = preventClose

    KeyEventService.registerKeyEvent $scope, 'pressedEsc', (elem, e) ->
      e.stopPropagation() if $scope.preventClose

    $scope.submit = FormService.submit $scope, $scope.session,
      flashSuccess:    'sign_in_form.signed_in'
      successCallback: (data) -> $window.location.reload() # Session.login(data)

    $scope.redirectTo = (href) ->
      $window.location = href

    $scope.providers = AppConfig.oauthProviders
