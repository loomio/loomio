EventBus = require('shared/services/event_bus')
{generateDayTimes, selectDayTimes} = require('shared/helpers/calendar')
TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'lmoTimepicker', ->
  scope: {poll: '=', date: '=?', addTimes: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_timepicker/lmo_timepicker.html'
  controller: ['$scope', ($scope) ->

    $scope.displayDayDate = () ->
      TimeService.displayDayDate($scope.date) unless $scope.setAllDates

    $scope.updateChips = (chips) ->
      if $scope.setAllDates
        $scope.poll.meetingOptions.addTimesToAll(chips)
      else
        $scope.poll.meetingOptions.addTimesToDate(chips, $scope.date)

    $scope.displayTime = (time) ->
      minute = if time.minute.length == 1 then '0'+time.minute else time.minute
      "#{time.hour}:#{minute}#{time.ampm}"

    $scope.setAllDates = $scope.date == undefined
    display = $scope.displayDayDate()
    $scope.chips = $scope.poll.meetingOptions.model[$scope.date]
    $scope.times = generateDayTimes(30)
    $scope.queryTimes = selectDayTimes
  ]
