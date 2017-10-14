angular.module('loomioApp').directive 'attachmentCollection', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/attachment/collection/attachment_collection.html'
