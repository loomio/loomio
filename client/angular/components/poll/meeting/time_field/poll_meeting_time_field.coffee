moment = require 'moment'

TimeService = require 'shared/services/time_service.coffee'

angular.module('loomioApp').directive 'pollMeetingTimeField', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/time_field/poll_meeting_time_field.html'
  controller: ['$scope', ($scope) ->
    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.option = {}
    $scope.times = TimeService.timesOfDay()
    $scope.minDate = new Date()

    $scope.addOption = ->
      return unless $scope.option.date
      $scope.poll.newOptionName = determineOptionName()
      $scope.poll.addOption()

    determineOptionName = ->
      optionName = moment($scope.option.date).format('YYYY-MM-DD')
      optionName = moment("#{optionName} #{$scope.option.time}", 'YYYY-MM-DD h:mma').toISOString() if ($scope.option.time or "").length
      optionName
  ]
