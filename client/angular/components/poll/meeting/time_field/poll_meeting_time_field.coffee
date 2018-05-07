TimeService = require 'shared/services/time_service'

angular.module('loomioApp').directive 'pollMeetingTimeField', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/time_field/poll_meeting_time_field.html'
  controller: ['$scope', ($scope) ->
    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.times = TimeService.timesOfDay()
    $scope.minDate = new Date()
  ]
