AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'pollMeetingFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/form_options/poll_meeting_form_options.html'
  controller: ['$scope', ($scope) ->

    $scope.selectForAll = true
    $scope.dateToTimes = {}

    $scope.displayDayDate =  (dates) ->
      if(dates.length == 1) then TimeService.displayDayDate(dates[0]) else "(#{dates.length} dates)"

    $scope.dateKey = (dates) ->
      if(dates.length == 1) then TimeService.displayDayDate(dates[0]) else "all"

    EventBus.listen $scope, 'dateSelected', (e, date) ->
      if _.contains $scope.poll.meetingDates, date
        _.pull $scope.poll.meetingDates, date
      else
        $scope.poll.meetingDates.push(date)
  ]
