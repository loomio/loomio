angular.module('loomioApp').directive 'threadCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/thread_card/thread_card.html'
  replace: true
  controller: ($scope, $rootScope, Records) ->
    $scope.lastLoadedSequenceId = 0
    $scope.firstLoadedSequenceId = 0
    $scope.loadingForward = false
    $scope.loadingBackward = false
    $scope.pageSize = 25

    $scope.init = ->
      $scope.discussion.markAsRead(0)
      $scope.loadEventsForwards()

    $scope.threadItemVisible = (item) ->
      $scope.discussion.markAsRead(item.sequenceId)
      $scope.loadEventsForwards() if $scope.loadMoreAfterReading(item)

    $scope.loadEventsForwards = ->
      return false if $scope.loadingForward
      $scope.loadingForward = true
      Records.events.fetch(discussion_key: $scope.discussion.key, from: $scope.lastLoadedSequenceId, per: $scope.pageSize).then ->
        $scope.lastLoadedSequenceId = Records.events.maxLoadedSequenceIdByDiscussion($scope.discussion)
        $scope.loadingForward = false

    $scope.loadEventsBackwards = ->
      return false if $scope.loadingBackward
      $scope.loadingBackward = true
      Records.events.fetch(discussion_key: $scope.discussion.key, from: $scope.firstLoadedSequenceId, per: $scope.pageSize, reverse: true).then ->
        $scope.firstLoadedSequenceId = Records.events.minLoadedSequenceIdByDiscussion($scope.discussion)
        $scope.loadingBackward = false

    $scope.canLoadBackwards = ->
      $scope.firstLoadedSequenceId > $scope.discussion.firstSequenceId and
      !$scope.loadingBackward

    $scope.loadMoreAfterReading = (item) ->
      item.sequenceId == $scope.lastLoadedSequenceId and
      item.sequenceId < $scope.discussion.lastSequenceId

    $scope.safeEvent = (kind) ->
      _.contains ['new_comment', 'new_motion', 'new_vote'], kind

    $scope.init()
