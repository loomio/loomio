angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, $document, $timeout, Records, LoadingService) ->

    $scope.pageSize = 30
    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0
    $scope.newActivitySequenceId = $scope.discussion.reader().lastReadSequenceId - 1
    visibleSequenceIds = []
    rollback = 2

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      target = _.parseInt($location.hash())
      if target >= $scope.discussion.firstSequenceId and target < $scope.discussion.lastSequenceId 
        # valid sequence id is specified in url
        $scope.initialLoaded  = _.max [target - rollback, 0]
        $scope.initialFocused = target
      else if $scope.discussion.isUnread()
        # discussion is unread
        $scope.initialLoaded  = $scope.discussion.reader().lastReadSequenceId
        $scope.initialFocused = _.max [$scope.initialLoaded - rollback, 0]
      else
        # discussion is read
        $scope.initialLoaded  = _.max [$scope.discussion.lastSequenceId - $scope.pageSize + 1, 0]
        $scope.initialFocused = _.max [$scope.discussion.lastSequenceId - rollback, 0]

      $scope.loadEventsForwards($scope.initialLoaded).then ->
        $rootScope.$broadcast 'threadPageEventsLoaded', $scope.initialFocused

    $scope.beforeCount = ->
      $scope.firstLoadedSequenceId - $scope.discussion.firstSequenceId

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
      $location.hash(_.min(visibleSequenceIds))
      $scope.loadEventsForwards($scope.lastLoadedSequenceId) if $scope.loadMoreAfterReading(item)

    $scope.loadEvents = ({from, per}) ->
      from = 0 unless from?
      per = $scope.pageSize unless per?

      Records.events.fetchByDiscussion($scope.discussion.key, {from: from, per: per}).then ->
        $scope.firstLoadedSequenceId = Records.events.minLoadedSequenceIdByDiscussion($scope.discussion)
        $scope.lastLoadedSequenceId  = Records.events.maxLoadedSequenceIdByDiscussion($scope.discussion)

    $scope.loadEventsForwards = (sequenceId) ->
      $scope.loadEvents(from: sequenceId)
    LoadingService.applyLoadingFunction $scope, 'loadEventsForwards'

    $scope.loadEventsBackwards = ->
      lastPageSequenceId = _.max [$scope.firstLoadedSequenceId - $scope.pageSize, 0]
      $scope.loadEvents(from: lastPageSequenceId)
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
