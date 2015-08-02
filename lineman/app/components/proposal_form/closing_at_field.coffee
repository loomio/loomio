angular.module('loomioApp').directive 'closingAtField', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/proposal_form/closing_at_field.html'
  replace: true
  controller: ($scope, CurrentUser) ->
    $scope.hours = [1..24]
    $scope.closingHour= $scope.proposal.closingAt.format('H')
    $scope.closingDate = $scope.proposal.closingAt.toDate()

    updateClosingAt = ->
      $scope.proposal.closingAt = moment($scope.closingDate).add($scope.closingHour, 'hours')

    $scope.$watch 'closingDate', updateClosingAt

    $scope.$watch 'closingHour', updateClosingAt

    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.timeZone = CurrentUser.timeZone
    $scope.closeDateTimePicker = ->
      $scope.dropdownIsOpen = false
