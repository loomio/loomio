angular.module('loomioApp').directive 'installSlackInviteForm', (Session, Records, CommunityService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/invite_form/install_slack_invite_form.html'
  controller: ($scope) ->
    $scope.fetchChannels = ->
      Records.identities.performCommand(Session.user().slackIdentity().id, 'channels').then (response) ->
        $scope.channels = response
      , (response) ->
        $scope.error = response.data.error

    $scope.submit = ->
      $scope.$emit 'processing'
      Session.currentGroup.publish($scope.identifier).then ->
        $scope.$emit 'inviteComplete'
      .finally ->
        $scope.$emit 'doneProcessing'
