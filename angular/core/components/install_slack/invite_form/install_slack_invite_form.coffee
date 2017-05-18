angular.module('loomioApp').directive 'installSlackInviteForm', (Session, Records, CommunityService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/invite_form/install_slack_invite_form.html'
  controller: ($scope) ->
    $scope.community = Records.communities.build
      communityType: 'slack'
      identityId: Session.user().slackIdentity().id

    $scope.fetchChannels = ->
      Records.identities.performCommand($scope.community.identityId, 'channels').then (response) ->
        $scope.channels = response
      , (response) ->
        $scope.error = response.data.error

    $scope.submit = CommunityService.submitCommunity $scope, $scope.community,
      prepareFn:       -> $scope.$emit 'processing'
      successCallback: -> $scope.$emit 'inviteComplete'
