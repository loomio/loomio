EventBus = require('shared/services/event_bus')
{generateDayTimes, selectDayTimes} = require('shared/helpers/calendar')
TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'lmoTimepicker', ->
  restrict: 'E'
  templateUrl: 'generated/components/lmo_timepicker/lmo_timepicker.html'
  controller: ['$scope', ($scope) ->

    $scope.selectedTimes = []
    $scope.selectedItem = null
    $scope.displayTime = (time) ->
      minute = if time.minute.length == 1 then '0'+time.minute else time.minute
      "#{time.hour}:#{minute}#{time.ampm}"

    $scope.times = generateDayTimes(30)
    $scope.queryTimes = selectDayTimes
  ]
