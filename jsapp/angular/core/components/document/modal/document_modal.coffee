angular.module('loomioApp').factory 'DocumentModal', ($timeout, LoadingService) ->
  templateUrl: 'generated/components/document/modal/document_modal.html'
  controller: ($scope, doc) ->
    $scope.document = doc.clone()
    LoadingService.listenForLoading $scope

    $timeout -> $scope.$emit 'initializeDocument', $scope.document
