angular.module('loomioApp').directive 'closingAtField', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_form/closing_at_field.html'
  replace: true
  controller: ($scope, CurrentUser) ->
    $scope.hours = [1..24]
    $scope.closingHour= $scope.proposal.closingAt.format('H')
    $scope.closingDate = $scope.proposal.closingAt.format("YYYY-MM-DD")

    $scope.dateToday = moment().format('YYYY-MM-DD')
    $scope.timeZone = CurrentUser.timeZone
    $scope.closeDateTimePicker = ->
      $scope.dropdownIsOpen = false
