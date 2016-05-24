angular.module('loomioApp').factory 'SignInForm', ->
  templateUrl: 'generated/components/sign_in_form/sign_in_form.html'
  controller: ($scope, $location, $window, preventClose, LmoUrlService, KeyEventService, Session, AppConfig, Records, FormService) ->
    $scope.session = Records.sessions.build(type: 'password')
    $scope.preventClose = preventClose

    KeyEventService.registerKeyEvent $scope, 'pressedEsc', (elem, e) ->
      e.stopPropagation() if $scope.preventClose

    $scope.submit = FormService.submit $scope, $scope.session,
      flashSuccess:    'sign_in_form.signed_in'
      successCallback: (data) -> Session.login(data)

    $scope.redirectTo = (href) ->
      $window.location = LmoUrlService.srcFor(href)

    $scope.providers = AppConfig.oauthProviders
