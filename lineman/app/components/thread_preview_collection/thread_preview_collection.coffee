angular.module('loomioApp').directive 'threadPreviewCollection', ->
  scope: {query: '=', limit: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview_collection/thread_preview_collection.html'
  replace: true
  controller: ($scope) ->

      $scope.importance = (thread) ->
        # we want to put starred threads in their own magnitude
        multiplier = if thread.isStarred() then -1000 else -1
        multiplier * thread.lastActivityAt
