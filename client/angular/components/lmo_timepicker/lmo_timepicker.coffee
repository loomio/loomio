EventBus = require('shared/services/event_bus')
{generateDayTimes, selectDayTimes} = require('shared/helpers/calendar')
TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'lmoTimepicker', ->
  scope: {date: '=?', addTimes: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_timepicker/lmo_timepicker.html'
  controller: ['$scope', ($scope) ->

    $scope.displayDayDate = () ->
      TimeService.displayDayDate($scope.date) unless $scope.setAllDates

    $scope.updateChips = (chip) ->
      $scope.$parent.setTimesForDate((if !$scope.setAllDates then $scope.displayDayDate($scope.date) else 'all'), $scope.chips)
      chip

    $scope.displayTime = (time) ->
      minute = if time.minute.length == 1 then '0'+time.minute else time.minute
      "#{time.hour}:#{minute}#{time.ampm}"

    $scope.setAllDates = $scope.date == undefined

    $scope.chips = []
    $scope.$parent.dateToTimes[$scope.displayDayDate()] = []
    $scope.times = generateDayTimes(30)
    $scope.queryTimes = selectDayTimes
  ]
