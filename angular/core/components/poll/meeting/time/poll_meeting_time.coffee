angular.module('loomioApp').directive 'pollMeetingTime', (TimeService) ->
  scope: {name: '=', zone: '='}
  template: "<span>{{displayDate(date, zone)}}</span>"
  controller: ($scope) ->
    $scope.date = moment($scope.name)
    $scope.displayDate = TimeService.displayDate
