angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, $document, $timeout, Records, AppConfig, LoadingService) ->

    $scope.pageSize = 30
    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0
    $scope.lastReadSequenceId = $scope.discussion.lastReadSequenceId
    $scope.hasNewActivity = $scope.discussion.isUnread()
    visibleSequenceIds = []

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      $scope.loadEventsForwards(
        commentId: $location.search().comment
        sequenceId: $scope.initialLoadSequenceId()).then ->
        $rootScope.$broadcast 'threadPageEventsLoaded'

    $scope.initialLoadSequenceId = ->
      if $scope.discussion.isUnread()
        $scope.discussion.lastReadSequenceId - 1
      else
        $scope.discussion.lastSequenceId - $scope.pageSize + 1

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
      $scope.loadEventsForwards(sequenceId: $scope.lastLoadedSequenceId) if $scope.loadMoreAfterReading(item)

    $scope.loadEvents = ({from, per, commentId}) ->
      from = 0 unless from?
      per = $scope.pageSize unless per?

      Records.events.fetchByDiscussion($scope.discussion.key, {from: from, comment_id: commentId, per: per}).then ->
        $scope.firstLoadedSequenceId = $scope.discussion.minLoadedSequenceId()
        $scope.lastLoadedSequenceId  = $scope.discussion.maxLoadedSequenceId()

    $scope.loadEventsForwards = ({commentId, sequenceId}) ->
      $scope.loadEvents(commentId: commentId, from: sequenceId)
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
      _.contains AppConfig.safeThreadItemKinds, kind

    $scope.events = ->
      _.filter $scope.discussion.events(), (event) -> $scope.safeEvent(event.kind)


    $scope.init()
    return
