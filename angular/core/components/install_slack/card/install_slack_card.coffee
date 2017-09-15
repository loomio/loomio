angular.module('loomioApp').directive 'installSlackCard', (ModalService, AbilityService, InstallSlackModal, ConfirmModal) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/card/install_slack_card.html'
  controller: ($scope) ->

    $scope.groupIdentity = ->
      $scope.group.groupIdentityFor('slack')

    $scope.install = ->
      ModalService.open InstallSlackModal, group: -> $scope.group

    $scope.canRemoveIdentity = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.remove = ->
      ModalService.open ConfirmModal,
        forceSubmit: -> false
        submit:      -> $scope.groupIdentity().destroy
        text:        ->
          title:    'install_slack.card.confirm_remove_title'
          helptext: 'install_slack.card.confirm_remove_helptext'
          flash:    'install_slack.card.identity_removed'
