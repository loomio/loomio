AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').directive 'pollCommonClosingAtField', ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/closing_at_field/poll_common_closing_at_field.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.hours = [1..24]
    $scope.closingHour= $scope.poll.closingAt.format('H')
    $scope.closingDate = $scope.poll.closingAt.toDate()
    $scope.minDate = new Date()

    updateClosingAt = ->
      $scope.poll.closingAt = moment($scope.closingDate).startOf('day').add($scope.closingHour, 'hours')

    $scope.$watch 'closingDate', updateClosingAt

    $scope.$watch 'closingHour', updateClosingAt

    $scope.hours = _.times 24, (i) -> i

    $scope.times = _.times 24, (i) ->
      i = "0#{i}" if i < 10
      moment("2015-01-01 #{i}:00").format('h a')

    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.timeZone = AppConfig.timeZone
  ]
