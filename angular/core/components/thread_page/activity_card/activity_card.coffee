angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $location, $mdDialog, $rootScope, $window, $timeout, Records, AppConfig, AbilityService, PaginationService, LoadingService, ModalService) ->

    $scope.$on 'fetchRecordsForPrint', (event, options = {}) ->
      $scope.loadEvents(per: Number.MAX_SAFE_INTEGER).then ->
        $mdDialog.cancel()
        $timeout -> $window.print()

    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0
    $scope.lastReadSequenceId = $scope.discussion.lastReadSequenceId
    $scope.hasNewActivity = $scope.discussion.isUnread()
    $scope.pagination = (current) ->
      PaginationService.windowFor
        current:  current
        min:      $scope.discussion.firstSequenceId
        max:      $scope.discussion.lastSequenceId
        pageType: 'activityItems'
    visibleSequenceIds = []

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      $scope.loadEventsForwards(
        commentId: $scope.activeCommentId
        sequenceId: $scope.initialLoadSequenceId()).then ->
        $rootScope.$broadcast 'threadPageEventsLoaded'

    $scope.initialLoadSequenceId = ->
      return $location.search().from                  if $location.search().from      # respond to ?from parameter
      return 0                                        if !AbilityService.isLoggedIn() # show beginning of discussion for logged out users
      return $scope.discussion.lastReadSequenceId - 5 if $scope.discussion.isUnread() # show newest unread content for logged in users
      return $scope.pagination($scope.discussion.lastSequenceId).prev                 # show latest content if the discussion has been read

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
      per  = per or $scope.pagination().pageSize

      Records.events.fetchByDiscussion($scope.discussion.key,
        from: from
        per: per
        comment_id: commentId).then ->
        $scope.firstLoadedSequenceId = $scope.discussion.minLoadedSequenceId()
        $scope.lastLoadedSequenceId  = $scope.discussion.maxLoadedSequenceId()

    $scope.loadEventsForwards = ({commentId, sequenceId}) ->
      $scope.loadEvents(commentId: commentId, from: sequenceId)
    LoadingService.applyLoadingFunction $scope, 'loadEventsForwards'

    $scope.loadEventsBackwards = ->
      $scope.loadEvents(from: $scope.pagination($scope.firstLoadedSequenceId).prev)
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

    $scope.noEvents = ->
      !$scope.loadEventsForwardsExecuting and !_.any($scope.events())

    $scope.init()
    return
