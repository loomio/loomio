angular.module('loomioApp').directive 'pollMeetingTimeField', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/time_field/poll_meeting_time_field.html'
  controller: ($scope) ->
    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.option = {}
    $scope.times = ['']

    _.times 24, (i) ->
      i = "0#{i}" if i < 10
      $scope.times.push moment("2015-01-01 #{i}:00").format('h:mm a')
      $scope.times.push moment("2015-01-01 #{i}:30").format('h:mm a')

    $scope.addOption = ->
      return unless $scope.option.date
      $scope.poll.pollOptionNames.push determineOptionName()
      $scope.option = {}

    $scope.hasTime = ->
      ($scope.option.time or "").length > 0

    determineOptionName = ->
      optionName = moment($scope.option.date).format('YYYY-MM-DD')
      if $scope.hasTime()
        optionName = moment("#{optionName} #{$scope.option.time}", 'YYYY-MM-DD h:mma').toISOString()
      optionName
