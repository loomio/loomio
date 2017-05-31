angular.module('loomioApp').directive 'pollCommonCalendarInvite', (Records, PollService, TimeService) ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/calendar_invite/poll_common_calendar_invite.html'
  controller: ($scope) ->

    $scope.options = _.map $scope.outcome.poll().pollOptions(), (option) ->
      id:    option.id
      value: TimeService.displayDate(moment(option.name))

    $scope.durations = [
      minutes: 30
      label: '30 minutes'
    ,
      minutes: 60
      label: '1 hour'
    ,
      minutes: 90
      label: '1 hour 30 minutes'
    ,
      minutes: 120
      label: '2 hours'
    ,
      minutes: 180
      label: '3 hours'
    ,
      minutes: 240
      label: '4 hours'
    ]

    $scope.outcome.calendarInvite = true
    $scope.outcome.pollOptionId = $scope.outcome.pollOptionId or _.first($scope.options).id
    $scope.outcome.customFields.event_duration = $scope.outcome.customFields.event_duration or _.first($scope.durations).minutes

    $scope.isDateOnly = ->
      option = Records.pollOptions.find($scope.outcome.pollOptionId) or {name: ""}
      TimeService.isDateOnly option.name
