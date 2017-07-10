angular.module('loomioApp').directive 'installSlackCard', ($location, $window, Session, ModalService, InstallSlackModal) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/card/install_slack_card.html'
  controller: ($scope) ->
    $scope.installed = ->
      $scope.group.slackChannelName && $scope.group.slackTeamName

    $scope.install = ->
      if Session.user().identityFor('slack')
        ModalService.open InstallSlackModal, group: -> $scope.group
      else
        $location.search('install_slack', true)
        $window.location.href = '/slack/oauth'
