angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, $document, $timeout, Records, LoadingService) ->

    $scope.pageSize = 30
    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0
    $scope.newActivitySequenceId = $scope.discussion.reader().lastReadSequenceId + 1
    $scope.initialSequenceId = _.max($scope.discussion.lastSequenceId - $scope.pageSize, 0)
    visibleSequenceIds = []
    rollback = 2

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      if _.isFinite(_.parseInt($location.hash()))
        # sequence id is specified in url
        $scope.initialLoaded  = _.parseInt($location.hash())
        $scope.initialFocused = _.max $scope.initialLoaded - rollback, 0
      else if $scope.discussion.isUnread()
        # discussion is unread
        $scope.initialLoaded  = $scope.discussion.reader().lastReadSequenceId
        $scope.initialFocused = _.max $scope.initialLoaded - rollback, 0
      else
        # discussion is read
        $scope.initialLoaded  = _.max $scope.discussion.lastSequenceId - $scope.pageSize, 0
        $scope.initialFocused = _.max $scope.discussion.lastSequenceId - rollback, 0

      $scope.loadEventsForwards($scope.initialLoaded).then ->
        $rootScope.broadcast 'threadPageEventsLoaded', $scope.initialFocused

    $scope.beforeCount = ->
      $scope.initialLoaded - $scope.discussion.firstSequenceId

    updateLastSequenceId = ->
      visibleSequenceIds = _.uniq(visibleSequenceIds)
      $rootScope.$broadcast('threadPosition', $scope.discussion, _.max(visibleSequenceIds))

    addSequenceId = (id) ->
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
      $scope.loadEventsForwards($scope.lastLoadedSequenceId) if $scope.loadMoreAfterReading(item)

    $scope.loadEvents = ({from, per, reverse}) ->
      from = 0 unless from?
      per = $scope.pageSize unless per?
      reverse = false unless reverse?

      Records.events.fetchByDiscussion($scope.discussion.key, {from: from, per: per, reverse: reverse}).then ->
        if reverse
          $scope.firstLoadedSequenceId = Records.events.minLoadedSequenceIdByDiscussion($scope.discussion)
        else
          $scope.lastLoadedSequenceId = Records.events.maxLoadedSequenceIdByDiscussion($scope.discussion)

    $scope.loadEventsForwards = (sequenceId) ->
      $scope.loadEvents(from: sequenceId)
    LoadingService.applyLoadingFunction $scope, 'loadEventsForwards'

    $scope.loadEventsBackwards = ->
      $scope.loadEvents(from: $scope.firstLoadedSequenceId, reverse: true)
    LoadingService.applyLoadingFunction $scope, 'loadEventsBackwards'

    $scope.canLoadBackwards = ->
      $scope.firstLoadedSequenceId > $scope.discussion.firstSequenceId and
      !($scope.loadEventsForwardsExecuting or $scope.loadEventsBackwardsExecuting)

    $scope.loadMoreAfterReading = (item) ->
      item.sequenceId == $scope.lastLoadedSequenceId and
      item.sequenceId < $scope.discussion.lastSequenceId

    $scope.safeEvent = (kind) ->
      _.contains ['new_comment', 'new_motion', 'new_vote'], kind

    $scope.init()
    return
