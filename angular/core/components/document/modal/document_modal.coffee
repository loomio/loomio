angular.module('loomioApp').factory 'DocumentModal', ->
  templateUrl: 'generated/components/document/modal/document_modal.html'
  controller: ($scope, model) ->
    $scope.model = model
