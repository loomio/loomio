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
      date = $scope.closingDate.toISOString().slice(0,10)
      $scope.proposal.closingAt = moment(date).add($scope.closingHour, 'hours')

    $scope.$watch 'closingDate', updateClosingAt

    $scope.$watch 'closingHour', updateClosingAt

    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.timeZone = jstz.determine().name()
    $scope.closeDateTimePicker = ->
      $scope.dropdownIsOpen = false
