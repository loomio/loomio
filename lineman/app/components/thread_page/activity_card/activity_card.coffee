angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, Records) ->
    $scope.loading = false
    $scope.pageSize = 50
    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      # want to request the window of items that best suits the read position
      if _.isFinite(_.parseInt($location.hash()))
        readPosition = _.parseInt($location.hash())
      else
        readPosition = $scope.discussion.unreadPosition()

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

    $scope.loadEvents = ({from, per, reverse}) ->
      from = 0 unless from?
      per = $scope.pageSize unless per?
      reverse = false unless reverse?

      return false if $scope.loading
      $scope.loading = true
      Records.events.fetch(discussion_key: $scope.discussion.key, from: from, per: per, reverse: reverse).then ->
        if reverse
          $scope.firstLoadedSequenceId = Records.events.minLoadedSequenceIdByDiscussion($scope.discussion)
        else
          $scope.lastLoadedSequenceId = Records.events.maxLoadedSequenceIdByDiscussion($scope.discussion)
        $scope.loading = false

    $scope.loadEventsForwards = ->
      $scope.loadEvents(from: $scope.lastLoadedSequenceId)

    $scope.loadEventsBackwards = ->
      $scope.loadEvents(from: $scope.firstLoadedSequenceId, reverse: true)

    $scope.canLoadBackwards = ->
      $scope.firstLoadedSequenceId > $scope.discussion.firstSequenceId and !$scope.loading

    $scope.loadMoreAfterReading = (item) ->
      item.sequenceId == $scope.lastLoadedSequenceId and
      item.sequenceId < $scope.discussion.lastSequenceId

    $scope.safeEvent = (kind) ->
      _.contains ['new_comment', 'new_motion', 'new_vote'], kind

    $scope.init()
    return
