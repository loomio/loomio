angular.module('loomioApp').directive 'threadPreviewCollection', ->
  scope: {query: '=', limit: '=?', order: '@'}
  restrict: 'E'
  template: require('./thread_preview_collection.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.vars =
      order: $scope.order || '-lastActivityAt'
  ]
