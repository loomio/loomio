Records     = require 'shared/services/records'
TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'pollCommonCalendarInvite', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/calendar_invite/poll_common_calendar_invite.html'
  controller: ['$scope', ($scope) ->

    $scope.options = _.map $scope.outcome.poll().pollOptions(), (option) ->
      id:        option.id
      value:     TimeService.displayDateAndTime(option.name)
      attendees: option.stances().length

    bestOption = _.head _.sortBy $scope.options, (option) ->
      -1 * option.attendees # sort descending, so the best option is first

    $scope.outcome.calendarInvite = true
    $scope.outcome.pollOptionId = $scope.outcome.pollOptionId or bestOption.id
    $scope.outcome.customFields.event_summary = $scope.outcome.customFields.event_summary or $scope.outcome.poll().title
  ]
