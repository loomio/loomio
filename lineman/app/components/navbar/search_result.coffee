angular.module('loomioApp').directive 'searchResult', ->
  scope: {result: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search_result.html'
  replace: true
  link: (scope, element, attrs) ->
