angular.module('loomioApp').factory 'DocumentModal', ->
  templateUrl: 'generated/components/document/modal/document_modal.html'
  controller: ($scope, doc) ->
    $scope.document = doc.clone()
