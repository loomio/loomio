Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').factory 'RegisteredAppForm', ($location, FormService, KeyEventService) ->
  templateUrl: 'generated/components/registered_app_form/registered_app_form.html'
  controller: ($scope, application) ->
    $scope.application = application.clone()

    actionName = if $scope.application.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.application,
      flashSuccess: "registered_app_form.messages.#{actionName}"
      flashOptions:
        name: -> $scope.application.name
      successCallback: (response) ->
        if $scope.application.isNew()
          $location.path LmoUrlService.oauthApplication(response.oauth_applications[0])

    $scope.upload = FormService.upload $scope, $scope.application,
      flashSuccess:   'registered_app_form.messages.logo_changed'
      submitFn:       $scope.application.uploadLogo
      loadingMessage: 'common.action.uploading'
      skipClose:      true
      successCallback: (response) ->
        $scope.application.logoUrl = response.data.oauth_applications[0].logo_url

    $scope.clickFileUpload = ->
      document.querySelector('.registered-app-form__logo-input').click()

    KeyEventService.submitOnEnter $scope
