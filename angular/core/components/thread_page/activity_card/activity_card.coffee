angular.module('loomioApp').directive 'activityCard', ( RecordLoader, $rootScope, Records)->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope) ->
    $scope.page =
      viewMode: 'unread'
      per: 100
      discussionKey: $scope.discussion.key

    applyViewMode = ->
      _.assign $scope.page,
        switch $scope.page.viewMode
          when "unread"
            orderBy: 'createdAt'
            minSequenceId: $scope.discussion.lastReadSequenceId || 1
            maxSequenceId: ($scope.discussion.lastReadSequenceId || 1) + ($scope.page.per - 1)
          when "oldest"
            orderBy: 'createdAt'
            minSequenceId: $scope.discussion.firstSequenceId
            maxSequenceId: ($scope.page.per - 1)
          # when "newest"
          #   orderBy: '-createdAt'
          #   minSequenceId: $scope.discussion.lastSequenceId - ($scope.page.per - 1)
          #   maxSequenceId: null
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
          $between: [$scope.page.minSequenceId, ($scope.page.maxSequenceId || Number.MAX_VALUE)]
        discussionId: $scope.discussion.id

      events = Records.events.collection.find(query)
      ids = _.pluck(events, 'id')
      # elements without their children
      _.reject(events, (e) -> _.includes(ids, e.parentId))

    $scope.noEvents = ->
      !_.any($scope.events())

    $scope.canNextPage = ->
      (($scope.page.minSequenceId + ($scope.page.per - 1)) < $scope.discussion.lastSequenceId) &&
      $scope.page.maxSequenceId != null

    $scope.canPreviousPage = ->
      $scope.page.minSequenceId > $scope.discussion.firstSequenceId

    $scope.nextPage = ->
      return unless $scope.canNextPage()

      $scope.page.minSequenceId += $scope.page.per
      $scope.page.maxSequenceId = $scope.page.minSequenceId + ($scope.page.per - 1)

      if $scope.page.maxSequenceId >= $scope.discussion.lastSequenceId
        $scope.page.maxSequenceId = null

      $scope.loader.loadFrom($scope.page.minSequenceId)

    $scope.previousPage = ->
      return unless $scope.canPreviousPage()

      $scope.page.minSequenceId -= $scope.page.per
      if $scope.page.minSequenceId < $scope.discussion.firstSequenceId
        $scope.page.minSequenceId = $scope.discussion.firstSequenceId

      $scope.page.maxSequenceId = $scope.page.minSequenceId + ($scope.page.per - 1)

      if $scope.page.maxSequenceId >= $scope.discussion.lastSequenceId
        $scope.page.maxSequenceId = null

      $scope.loader.loadFrom($scope.page.minSequenceId)

    $scope.init()
    return
