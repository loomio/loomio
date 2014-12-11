angular.module('loomioApp').directive 'formErrors', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/form_errors/form_errors.html'
  replace: true
  controller: 'FormErrorsController'
