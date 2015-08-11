angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, CurrentUser, LmoUrlService) ->
    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(CurrentUser)

    return
