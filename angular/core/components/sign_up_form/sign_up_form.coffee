angular.module('loomioApp').factory 'SignUpForm', ->
  templateUrl: 'generated/components/sign_up_form/sign_up_form.html'
  controller: ($scope, $location, $window, preventClose, ModalService, SignInForm, Session, AppConfig, Records, FormService) ->
    $scope.registration = Records.registrations.build()
    $scope.preventClose = preventClose

    $scope.submit = FormService.submit $scope, $scope.registration,
      flashSuccess:    'sign_up_form.signed_up'
      successCallback: (data) -> Session.login(data)

    $scope.openSignInModal = ->
      ModalService.open SignInForm

    $scope.redirectTo = (href) ->
      $window.location = href

    $scope.providers = AppConfig.oauthProviders
