angular.module('loomioApp').directive 'threadCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/thread_card/thread_card.html'
  replace: true
  controller: ($scope, $rootScope, Records) ->
    $scope.discussion.markAsRead(0)

    nextPage = 1

    busy = false

    $scope.threadItemVisible = (item) ->
      $scope.discussion.markAsRead(item.sequenceId)

    $scope.lastPage = false
    $scope.getNextPage = ->
      return false if busy or $scope.lastPage
      busy = true
      Records.events.fetch(discussion_key: $scope.discussion.key, page: nextPage).then (data) ->
        events = data.events
        $scope.lastPage = true if events.length == 0
        nextPage = nextPage + 1
        busy = false

    $scope.getNextPage()

    $scope.safeEvent = (kind) ->
      _.contains ['new_comment', 'new_motion', 'new_vote'], kind
