Records       = require 'shared/services/records'
LmoUrlService = require 'shared/services/lmo_url_service'

{ submitForm, uploadForm } = require 'shared/helpers/form'
{ submitOnEnter }      = require 'shared/helpers/keyboard'

angular.module('loomioApp').factory 'RegisteredAppForm', ->
  templateUrl: 'generated/components/registered_app_form/registered_app_form.html'
  controller: ['$scope', '$element', 'application', ($scope, $element, application) ->
    $scope.application = application.clone()

    actionName = if $scope.application.isNew() then 'created' else 'updated'
    $scope.submit = submitForm $scope, $scope.application,
      flashSuccess: "registered_app_form.messages.#{actionName}"
      flashOptions:
        name: -> $scope.application.name
      successCallback: (response) ->
        if $scope.application.isNew()
          LmoUrlService.goTo LmoUrlService.oauthApplication(response.oauth_applications[0])

    uploadForm $scope, $element, $scope.application,
      flashSuccess:   'registered_app_form.messages.logo_changed'
      submitFn:       $scope.application.uploadLogo
      loadingMessage: 'common.action.uploading'
      skipClose:      true
      disablePaste:   $scope.application.isNew()
      successCallback: (response) ->
        $scope.application.logoUrl = response.oauth_applications[0].logo_url

    submitOnEnter $scope
  ]
