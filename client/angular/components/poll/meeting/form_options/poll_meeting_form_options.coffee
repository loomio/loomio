AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'

{ applySequence } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'pollMeetingFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/form_options/poll_meeting_form_options.html'
  controller: ['$scope', ($scope) ->
    applySequence $scope, steps: ['dateOnly', 'collapsedTimes', 'expandedTimes']

    $scope.dateAndTime = (collapsed) ->
      $scope.currentStep = if collapsed
        'collapsedTimes'
      else
        'expandedTimes'

    $scope.setTimeMode = ->
      $scope.settingTimeMode = true

    $scope.dateOnly = ->
      $scope.settingTimeMode = false
      $scope.currentStep = 'dateOnly'

    EventBus.listen $scope, 'dateSelected', (e, date) ->
      if _.contains $scope.poll.meetingDates, date
        _.pull $scope.poll.meetingDates, date
      else
        $scope.poll.meetingDates.push(date)
  ]
