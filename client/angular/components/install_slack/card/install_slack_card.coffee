AppConfig      = require 'shared/services/app_config'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'installSlackCard', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/card/install_slack_card.html'
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      AbilityService.canAdministerGroup($scope.group) &&
      _.find AppConfig.identityProviders, (provider) -> provider.name == 'slack'

    $scope.groupIdentity = ->
      $scope.group.groupIdentityFor('slack')

    $scope.install = ->
      ModalService.open 'InstallSlackModal', group: -> $scope.group

    $scope.canRemoveIdentity = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.remove = ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit:     $scope.groupIdentity().destroy
        text:
          title:    'install_slack.card.confirm_remove_title'
          helptext: 'install_slack.card.confirm_remove_helptext'
          flash:    'install_slack.card.identity_removed'
  ]
