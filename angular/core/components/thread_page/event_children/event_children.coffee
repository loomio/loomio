angular.module('loomioApp').directive 'eventChildren', (Records, RecordLoader) ->
  scope: {parent: '=', page: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/event_children/event_children.html'
  replace: true
  controller: ($scope, $rootScope) ->

    $scope.loader = new RecordLoader
      collection: 'events'
      params:
        parent_id: $scope.parent.id
        discussion_key: $scope.page.discussionKey
      per: $scope.page.per

    $scope.children = ->
      # TODO, rather than within ids, check it's in the sequence_id range, or something else..
      # Records.events.collection.chain().find(parentId: $scope.parent.id, id: {$in: $scope.page.ids}).simplesort('pos').data()
      Records.events.collection.chain().find(parentId: $scope.parent.id).simplesort($scope.page.orderBy).data()

    noneLoaded = ->
      $scope.children().length == 0

    anyMissing = ->
      $scope.parent.childCount > 0 &&
      $scope.children().length < $scope.parent.childCount

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
      $scope.children().length

    $scope.firstPos = ->
      if $scope.children().length > 0
        $scope.children()[0].pos

    $scope.lastPos = ->
      if $scope.children().length > 0
        _.last($scope.children()).pos

    $scope.loadNext = ->
      Records

    $scope.loadPrevious = ->
