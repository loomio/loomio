angular.module('loomioApp').directive 'errorPage', ->
  scope: {error: '='}
  restrict: 'E'
  template: require('./error_page.haml')
  replace: true
