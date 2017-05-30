angular.module('loomioApp').directive 'installSlackInvitePreview', (Session, $timeout) ->
  templateUrl: 'generated/components/install_slack/invite_preview/install_slack_invite_preview.html'
  controller: ($scope) ->
    $timeout ->
      $scope.group     = Session.currentGroup
      $scope.userName  = Session.user().name
      $scope.timestamp = -> moment().format('h:ma')
