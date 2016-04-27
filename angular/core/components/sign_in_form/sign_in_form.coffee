angular.module('loomioApp').factory 'SignInForm', ->
  templateUrl: 'generated/components/sign_in_form/sign_in_form.html'
  controller: ($scope, $location, $window, Session, AppConfig, Records, FormService) ->
    $scope.session = Records.sessions.build(type: 'password')

    $scope.submit = FormService.submit $scope, $scope.session,
      flashSuccess:    'sign_in_form.signed_in'
      successCallback: Session.login

    $scope.redirectTo = (href) ->
      $window.location = href

    $scope.providers = AppConfig.oauthProviders
