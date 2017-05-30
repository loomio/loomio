angular.module('loomioApp').directive 'pollCommonCalendarInvite', (PollService, TimeService) ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/calendar_invite/poll_common_calendar_invite.html'
  controller: ($scope) ->
    $scope.outcome.calendarInvite = true

    $scope.options = _.map $scope.outcome.poll().pollOptions(), (option) ->
      id:    option.id
      value: TimeService.displayDate(moment(option.name))

    $scope.outcome.pollOptionId = _.first($scope.options).id
