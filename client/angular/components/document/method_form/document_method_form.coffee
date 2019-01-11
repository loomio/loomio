angular.module('loomioApp').directive 'documentMethodForm', ->
  scope: {document: '='}
  template: require('./document_method_form.haml')
