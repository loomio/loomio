angular.module('loomioApp').factory 'RegisteredAppForm', ->
  templateUrl: 'generated/components/registered_app_form/registered_app_form.html'
  controller: ($scope, application, Records, FormService, KeyEventService) ->
    $scope.application = application.clone()

    actionName = if $scope.application.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.application,
      flashSuccess: "oauth.registered_app_form.messages.#{actionName}"
      flashOptions:
        name: -> $scope.application.name

    KeyEventService.submitOnEnter $scope
