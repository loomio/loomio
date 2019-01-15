TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'pollMeetingTimeField', ->
  scope: {poll: '='}
  template: require('./poll_meeting_time_field.haml')
  controller: ['$scope', ($scope) ->
    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.times = TimeService.timesOfDay()
    $scope.minDate = new Date()
  ]
