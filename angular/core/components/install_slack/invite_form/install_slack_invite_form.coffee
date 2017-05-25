angular.module('loomioApp').directive 'installSlackInviteForm', ($timeout, Session, Records, CommunityService) ->
  templateUrl: 'generated/components/install_slack/invite_form/install_slack_invite_form.html'
  controller: ($scope) ->
    $timeout ->
      $scope.group = Session.currentGroup
      $scope.group.makeAnnouncement = true

    $scope.fetchChannels = ->
      return if $scope.channels
      Records.identities.performCommand(Session.user().slackIdentity().id, 'channels').then (response) ->
        $scope.channels = response
      , (response) ->
        $scope.error = response.data.error

    $scope.submit = ->
      $scope.$emit 'processing'
      $scope.group.publish($scope.identifier).then ->
        $scope.$emit 'inviteComplete'
      .finally ->
        $scope.$emit 'doneProcessing'
