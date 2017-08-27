angular.module('loomioApp').directive 'eventChildren', (Records, RecordLoader) ->
  scope: {discussion: '=', parent: '=', page: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/event_children/event_children.html'
  replace: true
  controller: ($scope, $rootScope) ->

    $scope.$on 'replyToCommentClicked', (parentComment) ->
      # $scope.parentComment = parentComment
      # $scope.discussion = parentComment.discussion()
      console.log "replyToCommentClicked"
      $scope.showReplyForm = true

    $scope.loader = new RecordLoader
      collection: 'events'
      params:
        parent_id: $scope.parent.id
        discussion_key: $scope.page.discussionKey
      per: $scope.page.per

    $scope.events = ->
      query =
        parentId: $scope.parent.id
        sequenceId:
          $between: [$scope.page.minSequenceId, ($scope.page.maxSequenceId || Number.MAX_VALUE)]
      delete query.sequenceId if $scope.showMore

      Records.events.collection.find(query)

    noneLoaded = ->
      $scope.events().length == 0

    anyMissing = ->
      $scope.parent.childCount > 0 &&
      $scope.events().length < $scope.parent.childCount

    $scope.anyPrevious = -> anyMissing() && !noneLoaded() && $scope.firstPos() > 0
    $scope.anyNext = -> anyMissing() && (noneLoaded() || ($scope.lastPos() + 1) < $scope.parent.childCount)

    $scope.previousCount = ->
      if $scope.anyPrevious()
        $scope.firstPos()
      else
        0

    $scope.nextCount = ->
      if !$scope.anyNext()
        0
      else if noneLoaded()
        $scope.parent.childCount
      else
        $scope.parent.childCount - ($scope.lastPos() + 1)

    $scope.loadedChildCount = ->
      $scope.events().length

    $scope.firstPos = ->
      if $scope.events().length > 0
        $scope.events()[0].pos

    $scope.lastPos = ->
      if $scope.events().length > 0
        _.last($scope.events()).pos

    $scope.loadMore = ->
      $scope.showMore = true
      $scope.loader.loadMore()

    $scope.loadPrevious = ->
      $scope.showMore = true
      $scope.loader.loadPrevious()

    $scope.showLess = ->
      $scope.showMore = false
