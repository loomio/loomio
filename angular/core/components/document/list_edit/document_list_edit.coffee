angular.module('loomioApp').directive 'documentListEdit', ->
  scope: {document: '='}
  replace: true
  templateUrl: 'generated/components/document/list_edit/document_list_edit.html'
