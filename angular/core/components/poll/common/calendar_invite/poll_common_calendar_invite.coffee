angular.module('loomioApp').directive 'pollCommonCalendarInvite', (Records, PollService, TimeService) ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/calendar_invite/poll_common_calendar_invite.html'
  controller: ($scope) ->

    $scope.options = _.map $scope.outcome.poll().pollOptions(), (option) ->
      id:    option.id
      value: TimeService.displayDate(moment(option.name))

    $scope.outcome.calendarInvite = true
    $scope.outcome.pollOptionId = $scope.outcome.pollOptionId or _.first($scope.options).id
    $scope.outcome.statement = $scope.outcome.statement or $scope.outcome.poll().title
