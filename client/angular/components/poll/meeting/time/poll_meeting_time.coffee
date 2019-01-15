TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'pollMeetingTime', ->
  scope: {name: '=', zone: '='}
  replace: true
  template: require('./poll_meeting_time.haml')
  controller: ['$scope', ($scope) ->
    $scope.sameYear    = TimeService.sameYear
    $scope.displayYear  = TimeService.displayYear
    $scope.displayDay  = TimeService.displayDay
    $scope.displayDate = TimeService.displayDate
    $scope.displayTime = TimeService.displayTime
    $scope.fullDayDate = TimeService.fullDayDate
  ]
