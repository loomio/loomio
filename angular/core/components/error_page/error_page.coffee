angular.module('loomioApp').directive 'errorPage', ->
  scope: {error: '='}
  restrict: 'E'
  templateUrl: 'generated/components/error_page/error_page.html'
  replace: true
