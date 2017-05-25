angular.module('loomioApp').directive 'installSlackInvitePreview', (Session) ->
  scope: {poll: '=', message: '='}
  templateUrl: 'generated/components/install_slack/invite_preview/install_slack_invite_preview.html'
  controller: ($scope) ->
    $scope.userName  = Session.user().name
    $scope.timestamp = -> moment().format('h:ma')
