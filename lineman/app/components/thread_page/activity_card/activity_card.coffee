angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
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

    $scope.lastSequenceId = 0
    visibleSequenceIds = []

    updateLastSequenceId = ->
      visibleSequenceIds = _.uniq(visibleSequenceIds)
      $scope.lastSequenceId = _.max(visibleSequenceIds)
      $rootScope.$broadcast('threadPosition', $scope.discussion, $scope.lastSequenceId)

    addSequenceId = (id) =>
      visibleSequenceIds.push(id)
      updateLastSequenceId()

    removeSequenceId = (id) ->
      visibleSequenceIds = _.without(visibleSequenceIds, id)
      updateLastSequenceId()

    $scope.threadItemHidden = (item) ->
      removeSequenceId(item.sequenceId)

    $scope.threadItemVisible = (item) ->
      addSequenceId(item.sequenceId)
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
