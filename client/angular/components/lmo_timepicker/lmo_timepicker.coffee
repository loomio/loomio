EventBus = require('shared/services/event_bus')
{generateDayTimes, selectDayTimes} = require('shared/helpers/calendar')

angular.module('loomioApp').directive 'lmoTimepicker', ->
  scope: {date:'='}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_timepicker/lmo_timepicker.html'
  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.selectedTimes = []
    $scope.selectedItem = null

    $scope.displayTime = (time) ->
      minute = if time.minute.length == 1 then '0'+time.minute else time.minute
      "#{time.hour}:#{minute}#{time.ampm}"

    $scope.times = generateDayTimes(30)
    $scope.queryTimes = selectDayTimes
  ]
