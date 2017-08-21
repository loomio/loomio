angular.module('loomioApp').directive 'activityCard', ( RecordLoader, $rootScope, Records)->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope) ->
    $scope.page =
      viewMode: 'unread'
      per: 2
      discussionKey: $scope.discussion.key

    applyViewMode = ->
      _.assign $scope.page,
        switch $scope.page.viewMode
          when "unread"
            orderBy: 'pos'
            minSequenceId: $scope.discussion.lastReadSequenceId
            maxSequenceId: $scope.discussion.lastReadSequenceId + $scope.page.per
          when "oldest"
            orderBy: 'pos'
            minSequenceId: 1
            maxSequenceId: $scope.page.per
          when "newest"
            orderBy: '-pos'
            minSequenceId: $scope.discussion.lastSequenceId - $scope.page.per
            maxSequenceId: null
          else
            console.error "invalid viewMode: #{$scope.page.viewMode}"

    $scope.init = ->
      applyViewMode()

      $scope.loader = new RecordLoader
        collection: 'events'
        params:
          discussion_key: $scope.discussion.key
        per: $scope.page.per
        from: $scope.page.from
        then: (data) ->
          $rootScope.$broadcast 'threadPageEventsLoaded'

      $scope.loader.loadMore()

    $scope.events = ->
      # scoped to only those within the sequence window
      query =
        sequenceId:
          $between: [$scope.page.minSequenceId, ($scope.page.maxSequenceId || $scope.discussion.lastSequenceId)]
        discussionId: $scope.discussion.id

      console.log query
      events = Records.events.collection.find(query)
      ids = _.pluck(events, 'id')
      console.log events
      # elements without their children
      _.reject(events, (e) -> _.includes(ids, e.parentId))

    $scope.noEvents = ->
      !_.any($scope.events())

    $scope.canNextPage = ->
      (($scope.page.minSequenceId + $scope.page.per) < $scope.discussion.lastSequenceId) &&
      $scope.page.maxSequenceId != null

    $scope.canPreviousPage = ->
      $scope.page.minSequenceId > 1

    $scope.nextPage = ->
      return unless $scope.canNextPage()

      $scope.page.maxSequenceId += $scope.page.per
      $scope.page.minSequenceId = $scope.page.maxSequenceId - $scope.page.per

      if $scope.page.maxSequenceId > $scope.discussion.lastSequenceId
        $scope.page.maxSequenceId = null
        $scope.page.minSequenceId = $scope.discussion.lastSequenceId - $scope.page.per

      $scope.loader.loadFrom($scope.page.minSequenceId)

    $scope.previousPage = ->
      return unless $scope.canPreviousPage()

      if $scope.page.maxSequenceId == null
        $scope.page.maxSequenceId = $scope.discussion.lastSequenceId - $scope.page.per
      else
        $scope.page.maxSequenceId -= $scope.page.per

      $scope.page.minSequenceId = $scope.page.maxSequenceId - $scope.page.per

      $scope.loader.loadFrom($scope.page.minSequenceId)

    $scope.init()
    return
