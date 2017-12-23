Session = require 'shared/services/session.coffee'
Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'installSlackInviteForm', ($timeout, FormService, KeyEventService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/invite_form/install_slack_invite_form.html'
  controller: ($scope) ->
    $scope.groupIdentity = Records.groupIdentities.build(
      groupId: $scope.group.id
      identityType: 'slack'
      makeAnnouncement: true
    )

    $scope.fetchChannels = ->
      return if $scope.channels
      Records.identities.performCommand(Session.user().identityFor('slack').id, 'channels').then (response) ->
        $scope.channels = response
      , (response) ->
        $scope.error = response.data.error

    $scope.submit = FormService.submit $scope, $scope.groupIdentity,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.groupIdentity.customFields.slack_channel_name = '#' + _.find($scope.channels, (c) ->
          c.id == $scope.groupIdentity.customFields.slack_channel_id
        ).name
      successCallback: -> $scope.$emit 'nextStep'
      cleanupFn:       -> $scope.$emit 'doneProcessing'

    KeyEventService.submitOnEnter $scope, anyEnter: true
    $scope.$emit 'focus'
