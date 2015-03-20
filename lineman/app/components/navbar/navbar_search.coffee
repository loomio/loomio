angular.module('loomioApp').directive 'navbarSearch', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: 'NavbarSearchController'
  link: (scope, element, attrs) ->
