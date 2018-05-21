EventBus = require('shared/services/event_bus')
{generateDayTimes, searchDayTimes} = require('shared/helpers/calendar')

angular.module('loomioApp').directive 'lmoTimepicker', ->
  scope: {date:'='}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_timepicker/lmo_timepicker.html'
  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.selectedTimes = []

    $scope.searchText = null

    $scope.selectedItem = null

    $scope.displayTime = (time) ->
      time

    $scope.times = generateDayTimes(30)

    $scope.queryTimes =  ->
      searchDayTimes($scope.searchText, $scope.times).map((time) ->
        {display:time}
      )

    $scope.searchTextChange =  (text) ->
      $scope.searchText = text
      console.log("text change: ", text)

    $scope.selectedItemChange = (item) ->
      console.log("time selected: ", item)
      $scope.selectedTimes.push(item.display)

  ]
