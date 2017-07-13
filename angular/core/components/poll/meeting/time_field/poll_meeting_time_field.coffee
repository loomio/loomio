angular.module('loomioApp').directive 'pollMeetingTimeField', (TimeService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/time_field/poll_meeting_time_field.html'
  controller: ($scope) ->
    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.option = {}
    $scope.times = TimeService.timesOfDay()
    $scope.minDate = new Date()

    $scope.addOption = ->
      optionName = determineOptionName()
      return unless $scope.option.date && !_.contains($scope.poll.pollOptionNames, optionName)
      $scope.poll.pollOptionNames.push optionName
    $scope.$on 'addPollOption', $scope.addOption

    $scope.hasTime = ->
      ($scope.option.time or "").length > 0

    determineOptionName = ->
      optionName = moment($scope.option.date).format('YYYY-MM-DD')
      if $scope.hasTime()
        optionName = moment("#{optionName} #{$scope.option.time}", 'YYYY-MM-DD h:mma').toISOString()
      optionName
