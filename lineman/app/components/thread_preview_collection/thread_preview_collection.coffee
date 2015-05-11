angular.module('loomioApp').directive 'threadPreviewCollection', ->
  scope: {query: '=', limit: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview_collection/thread_preview_collection.html'
  replace: true
  controller: ($scope, Records, CurrentUser) ->
    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(CurrentUser)

    return
