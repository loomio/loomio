angular.module('loomioApp').directive 'documentListEdit', ->
  scope: {document: '='}
  replace: true
  template: require('./document_list_edit.haml')
