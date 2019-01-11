angular.module('loomioApp').directive 'validationErrors', ->
  scope: {subject: '=', field: '@'}
  restrict: 'E'
  template: require('./validation_errors.haml')
  replace: true
