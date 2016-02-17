angular.module('loomioApp').directive 'formErrors', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/form_errors/form_errors.html'
  replace: true
  controller: 'FormErrorsController'
