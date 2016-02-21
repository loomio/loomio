angular.module('loomioApp').factory 'OauthApplicationForm', ->
  templateUrl: 'generated/components/oauth_application_form/oauth_application_form.html'
  controller: ($scope, application, Records, FormService, KeyEventService) ->
    $scope.application = application.clone()

    actionName = if $scope.application.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.application,
      flashSuccess: "oauth_application_form.messages.#{actionName}"
      flashOptions:
        name: -> $scope.application.name

    KeyEventService.submitOnEnter $scope
