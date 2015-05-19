angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, $document, $timeout, Records, LoadingService) ->
    reader = $scope.discussion.reader()

    $scope.pageSize = 30
    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0
    $scope.newActivitySequenceId = reader.lastReadSequenceId + 1
    visibleSequenceIds = []
    rollback = 2

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      $scope.firstLoadedSequenceId = focusSequenceId() - rollback

      if ($scope.firstLoadedSequenceId + $scope.pageSize - 1) > $scope.discussion.lastSequenceId
        $scope.firstLoadedSequenceId = $scope.discussion.lastSequenceId - $scope.pageSize + 1

      $scope.loadEventsForwards($scope.firstLoadedSequenceId - 1).then (events) ->
        $timeout ->
          elem = document.querySelector(focusSelector())
          console.log 'scrolling to ', focusSelector(), elem
          angular.element().focus(elem)
          $document.scrollToElement(elem, 100)

    focusSelector = ->
      if _.isFinite(_.parseInt($location.hash()))
        # startPosition is manually specified in hash
        "##{$location.hash()}"
      else if $location.hash() == 'proposal'
        '.current-proposal-card'
      else if $scope.lastReadSequenceId == -1 or $scope.discussion.lastSequenceId == 0
        # first view of thread. Start at the top
        '.thread-context'
      else if $scope.discussion.lastSequenceId == reader.lastReadSequenceId
        # already read everything.. take them to the bottom
        '.activity-card__last-item'
      else
        '.activity-card__new-activity'

    focusSequenceId = ->
      if _.isFinite(_.parseInt($location.hash()))
        # startPosition is manually specified in hash
        _.parseInt($location.hash())
      else if $scope.lastReadSequenceId == -1
        # first view of thread. Start at the top
        0
      else if $scope.discussion.lastSequenceId == reader.lastReadSequenceId
        # already read everything.. take them to the bottom
        $scope.discussion.lastSequenceId
      else
        # start at first unread thing
        $scope.discussion.lastSequenceId + 1

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
      $scope.loadEventsForwards() if $scope.loadMoreAfterReading(item)

    $scope.loadEvents = ({from, per, reverse}) ->
      from = 0 unless from?
      per = $scope.pageSize unless per?
      reverse = false unless reverse?

      Records.events.fetchByDiscussion($scope.discussion.key, {from: from, per: per, reverse: reverse}).then ->
        if reverse
          $scope.firstLoadedSequenceId = Records.events.minLoadedSequenceIdByDiscussion($scope.discussion)
        else
          $scope.lastLoadedSequenceId = Records.events.maxLoadedSequenceIdByDiscussion($scope.discussion)

    $scope.loadEventsForwards = (sequenceId = $scope.lastLoadedSequenceId) ->
      $scope.loadEvents(from: sequenceId)
    LoadingService.applyLoadingFunction $scope, 'loadEventsForwards'

    $scope.loadEventsBackwards = ->
      $scope.loadEvents(from: $scope.firstLoadedSequenceId, reverse: true)
    LoadingService.applyLoadingFunction $scope, 'loadEventsBackwards'

    $scope.canLoadBackwards = ->
      $scope.firstLoadedSequenceId > $scope.discussion.firstSequenceId and
      !($scope.loadEventsForwards or $scope.loadEventsBackwards)

    $scope.loadMoreAfterReading = (item) ->
      item.sequenceId == $scope.lastLoadedSequenceId and
      item.sequenceId < $scope.discussion.lastSequenceId

    $scope.safeEvent = (kind) ->
      _.contains ['new_comment', 'new_motion', 'new_vote'], kind

    $scope.init()
    return
