angular.module('loomioApp').directive 'navbarSearch', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/js/modules/navbar/navbar_search.html'
  replace: true
  controller: 'NavbarSearchController'
  link: (scope, element, attrs) ->
