AppConfig = require 'shared/services/app_config.coffee'
EventBus  = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'pollMeetingForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/meeting/form/poll_meeting_form.html'
  controller: ['$scope', ($scope) ->

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.durations = AppConfig.durations
    $scope.poll.customFields.meeting_duration = $scope.poll.customFields.meeting_duration or 60
    $scope.poll.customFields.can_respond_maybe = $scope.poll.customFields.can_respond_maybe or false

    if $scope.poll.isNew()
      $scope.poll.closingAt = moment().add(2, 'day')
      $scope.poll.notifyOnParticipate = true
      $scope.poll.canRespondMaybe = false
      $scope.poll.makeAnnouncement = true if $scope.poll.group()

    EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
      $scope.poll.customFields.time_zone = zone
  ]
