AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'pollMeetingFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/form_options/poll_meeting_form_options.html'
  controller: ['$scope', ($scope) ->
    $scope.displayDayDate = (date) ->
      TimeService.displayDayDate(date)

    $scope.showAddTimes = -> $scope.addTimes = true

    EventBus.listen $scope, 'dateSelected', (e, date) ->
      if _.contains $scope.poll.meetingDates, date
        _.pull $scope.poll.meetingDates, date
      else
        $scope.poll.meetingDates.push(date)
  ]
