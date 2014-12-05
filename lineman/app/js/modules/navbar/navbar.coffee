angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/js/modules/navbar/navbar.html'
  replace: true
  controller: 'NavbarController'
  link: (scope, element, attrs) ->
