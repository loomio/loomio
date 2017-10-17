angular.module('loomioApp').factory 'DocumentModal', (LoadingService) ->
  templateUrl: 'generated/components/document/modal/document_modal.html'
  controller: ($scope, doc) ->
    $scope.document = doc.clone()
    LoadingService.listenForLoading $scope
