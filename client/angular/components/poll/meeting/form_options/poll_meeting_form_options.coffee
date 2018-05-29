AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
TimeService = require 'shared/services/time_service'

{ applySequence } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'pollMeetingFormOptions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/form_options/poll_meeting_form_options.html'
  controller: ['$scope', ($scope) ->

    save = () => $scope.poll.pollOptionNames = $scope.poll.meetingOptions.getPollOptionNames()
    load = () => $scope.poll.meetingOptions.parsePollOptions($scope.poll.pollOptionNames)

    $scope.dateOnly = ->
      $scope.poll.meetingOptions.dateOnlyMode()
      $scope.settingTimeMode = false

    $scope.collapsedMode =  ->
      $scope.poll.meetingOptions.collapsedMode()
      save()

    $scope.expandedMode = ->
      $scope.poll.meetingOptions.expandedMode()
      save()

    $scope.setTimeMode = ->
      $scope.settingTimeMode = true

    EventBus.listen $scope, 'dateSelected', (e, date) ->
      $scope.poll.meetingOptions.toggleCalendarDate(date)

    $scope.setTimesForDate = (date, times) ->
      $scope.poll.meetingOptions.addTimesToDate(times, date)

  ]
