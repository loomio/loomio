angular.module('loomioApp').directive 'pollMeetingForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/meeting/form/poll_meeting_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, TimeService) ->

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    if $scope.poll.isNew()
      $scope.poll.closingAt = moment().add(2, 'day')
      $scope.poll.notifyOnParticipate = true
      $scope.poll.makeAnnouncement = true if $scope.poll.group()

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.$broadcast 'addOption'

    $scope.$on 'timeZoneSelected', (e, zone) ->
      $scope.poll.customFields.time_zone = zone

    KeyEventService.submitOnEnter($scope)
