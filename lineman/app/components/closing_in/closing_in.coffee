angular.module('loomioApp').directive 'closingIn', ->
  scope: {time: '='}
  restrict: 'E'
  templateUrl: 'generated/components/closing_in/closing_in.html'
  replace: true
