angular.module('loomioApp').directive 'installSlackInviteForm', ($timeout, Session, KeyEventService, Records, CommunityService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/invite_form/install_slack_invite_form.html'
  controller: ($scope) ->
    $scope.group.makeAnnouncement = true

    $scope.fetchChannels = ->
      return if $scope.channels
      Records.identities.performCommand(Session.user().slackIdentity().id, 'channels').then (response) ->
        $scope.channels = response
      , (response) ->
        $scope.error = response.data.error

    $scope.submit = ->
      $scope.$emit 'processing'
      channel = '#' + _.find($scope.channels, (c) -> c.id == $scope.identifier).name
      $scope.group.publish($scope.identifier, channel).then ->
        $scope.$emit 'inviteComplete'
      .finally ->
        $scope.$emit 'doneProcessing'

    KeyEventService.submitOnEnter $scope, anyEnter: true
    $scope.$emit 'focus'
