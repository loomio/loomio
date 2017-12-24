{ listenForLoading } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').factory 'DocumentModal', ($timeout) ->
  templateUrl: 'generated/components/document/modal/document_modal.html'
  controller: ($scope, doc) ->
    $scope.document = doc.clone()
    listenForLoading $scope

    $timeout -> $scope.$emit 'initializeDocument', $scope.document
