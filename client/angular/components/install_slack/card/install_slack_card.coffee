AppConfig      = require 'shared/services/app_config.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'installSlackCard', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/card/install_slack_card.html'
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      AbilityService.canAdministerGroup($scope.group) &&
      _.find configData.identityProviders, (provider) -> provider.name == name

    $scope.groupIdentity = ->
      $scope.group.groupIdentityFor('slack')

    $scope.install = ->
      ModalService.open 'InstallSlackModal', group: -> $scope.group

    $scope.canRemoveIdentity = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.remove = ->
      ModalService.open 'ConfirmModal',
        forceSubmit: -> false
        submit:      -> $scope.groupIdentity().destroy
        text:        ->
          title:    'install_slack.card.confirm_remove_title'
          helptext: 'install_slack.card.confirm_remove_helptext'
          flash:    'install_slack.card.identity_removed'
  ]
