angular.module('loomioApp').directive 'pollMeetingForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/meeting/form/poll_meeting_form.html'
  controller: ($scope, AppConfig) ->

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.durations = AppConfig.durations
    $scope.poll.customFields.meeting_duration = $scope.poll.customFields.meeting_duration or 60

    if $scope.poll.isNew()
      $scope.poll.closingAt = moment().add(2, 'day')
      $scope.poll.notifyOnParticipate = true
      $scope.poll.makeAnnouncement = true if $scope.poll.group()

    $scope.$on 'timeZoneSelected', (e, zone) ->
      $scope.poll.customFields.time_zone = zone
