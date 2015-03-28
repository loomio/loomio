angular.module('loomioApp').directive 'closingAtField', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_form/closing_at_field.html'
  replace: true
  controller: ($scope) ->
    $scope.closeDateTimePicker = ->
      $scope.dropdownIsOpen = false
