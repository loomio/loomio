angular.module('loomioApp').directive 'threadPreviewCollection', ->
  scope: {query: '=', limit: '=?', order: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview_collection/thread_preview_collection.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.vars =
      order: $scope.order || '-lastActivityAt'
  ]
