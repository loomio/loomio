EventBus = require 'shared/services/event_bus'

{ submitForm } = require 'shared/helpers/form'
{ submitOnEnter }    = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'installMicrosoftFormActions', ->
  scope: {groupIdentity: '='}
  replace: true
  templateUrl: 'generated/components/install_microsoft/form_actions/install_microsoft_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitForm $scope, $scope.groupIdentity,
      prepareFn: ->
        $scope.groupIdentity.customFields.event_kinds = _.map $scope.groupIdentity.eventKinds, (value, key) -> key if value

      flashSuccess: 'install_microsoft.form.webhook_installed'
      successCallback: -> EventBus.emit $scope, '$close'

    submitOnEnter $scope
  ]
