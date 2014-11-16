angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/templates/navbar.html'
  replace: true
  controller: 'NavbarController'
  link: (scope, element, attrs) ->
