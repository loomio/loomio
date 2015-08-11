angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, $window, $router, Records, CurrentUser, LmoUrlService) ->
    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(CurrentUser)

    $scope.navigateTo = ($event) ->
      target = LmoUrlService.discussion($scope.thread)
      if $event.metaKey
        $window.open target, '_tab'
      else
        $router.navigate target
      true # so we don't return a $window expression, which angular complains about

    return
