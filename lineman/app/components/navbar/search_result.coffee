angular.module('loomioApp').directive 'searchResult', ->
  scope: {result: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/search_result.html'
  replace: true
