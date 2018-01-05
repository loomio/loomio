Session  = require 'shared/services/session.coffee'
Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

{ submitForm }    = require 'angular/helpers/form.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'installSlackInviteForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/invite_form/install_slack_invite_form.html'
  controller: ['$scope', ($scope) ->
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

    $scope.submit = submitForm $scope, $scope.groupIdentity,
      prepareFn: ->
        EventBus.emit $scope, 'processing'
        $scope.groupIdentity.customFields.slack_channel_name = '#' + _.find($scope.channels, (c) ->
          c.id == $scope.groupIdentity.customFields.slack_channel_id
        ).name
      successCallback: -> EventBus.emit $scope, 'nextStep'
      cleanupFn:       -> EventBus.emit $scope, 'doneProcessing'

    submitOnEnter $scope, anyEnter: true
    EventBus.emit $scope, 'focus'
  ]
