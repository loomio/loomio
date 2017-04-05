angular.module('loomioApp').directive 'closingAtField', (AppConfig) ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/proposal_form/closing_at_field.html'
  replace: true
  controller: ($scope) ->
    $scope.hours = [1..24]
    $scope.closingHour= $scope.proposal.closingAt.format('H')
    $scope.closingDate = $scope.proposal.closingAt.toDate()

    updateClosingAt = ->
      $scope.proposal.closingAt = moment($scope.closingDate).startOf('day').add($scope.closingHour, 'hours')

    $scope.$watch 'closingDate', updateClosingAt

    $scope.$watch 'closingHour', updateClosingAt

    $scope.hours = _.times 24, (i) -> i

    $scope.times = _.times 24, (i) ->
      i = "0#{i}" if i < 10
      moment("2015-01-01 #{i}:00").format('h a')

    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.timeZone = AppConfig.timeZone
