AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
TimeService = require 'shared/services/time_service'

{ applySequence } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'pollMeetingFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/form_options/poll_meeting_form_options.html'
  controller: ['$scope', ($scope) ->
    applySequence $scope, steps: ['dateOnly', 'collapsedTimes', 'expandedTimes']

    $scope.collapsedMode =  ->
      $scope.currentStep = 'collapsedTimes'
      $scope.poll.submitDateTimes($scope.dateToTimes)

    $scope.expandedMode = ->
      if $scope.dateToTimes['all']
        $scope.dateToTimes = _.fromPairs _.map($scope.poll.meetingDates, (date) ->
          [TimeService.displayDayDate(date) , $scope.dateToTimes['all'].slice()])

      $scope.currentStep = 'expandedTimes'
      $scope.poll.submitDateTimes($scope.dateToTimes)

    $scope.setTimeMode = ->
      $scope.settingTimeMode = true

    $scope.dateOnly = ->
      $scope.dateToTimes = {}
      $scope.settingTimeMode = false
      $scope.currentStep = 'dateOnly'
      $scope.poll.submitAllDayDates()

    EventBus.listen $scope, 'dateSelected', (e, date) ->
      if _.contains $scope.poll.meetingDates, date
        _.pull $scope.poll.meetingDates, date
      else
        $scope.poll.meetingDates.push(date)

      if($scope.currentStep == 'dateOnly')
        $scope.poll.submitAllDayDates()

    $scope.setTimesForDate = (date, times) ->
      $scope.dateToTimes[date] = times
      $scope.poll.submitDateTimes($scope.dateToTimes)

    $scope.poll.repopulateMeetingDates()

    if ($scope.poll.isNew() || $scope.poll.hasDatesOnly())
      #recover the dates
      $scope.dateOnly()
    else
      #recover the date times
      $scope.dateToTimes = $scope.poll.recoverDateTimes()
      $scope.expandedMode()

  ]
