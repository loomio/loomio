angular.module('loomioApp').directive 'activityCard', (ChronologicalEventWindow, NestedEventWindow, RecordLoader, $mdDialog, $timeout, $window, ThreadPositionService)->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  controller: ($scope) ->

    $scope.setDefaults = ->
      $scope.per = 10
      $scope.renderMode = "chronological"
      $scope.initialPosition = ThreadPositionService.initialPosition($scope.discussion)
      $scope.initialSequenceId = ThreadPositionService.initialSequenceId($scope.initialPosition, $scope.discussion, $scope.per)
      $scope.position = $scope.positionForSelect()

    $scope.$on 'fetchRecordsForPrint', (event, options = {}) ->
      $scope.eventWindow.loadAll().then ->
        $mdDialog.cancel()
        $timeout -> $window.print()

    $scope.positionForSelect = ->
      if _.include(['requested', 'context'], $scope.initialPosition)
        "beginning"
      else
        $scope.initialPosition

    $scope.init = (position = $scope.initialPosition) ->
      $scope.loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: $scope.discussion.id
          order: 'sequence_id'
          from: $scope.initialSequenceId
          per: $scope.per

      $scope.loader.loadMore().then ->
        if $scope.renderMode == "chronological"
          $scope.eventWindow = new ChronologicalEventWindow
            discussion: $scope.discussion
            initialSequenceId: $scope.initialSequenceId
            per: $scope.per
        else
          $scope.eventWindow = new NestedEventWindow
            discussion: $scope.discussion
            parentEvent: $scope.discussion.createdEvent()
            initialSequenceId: $scope.initialSequenceId
            per: $scope.per

        $scope.$emit('threadPageScrollToSelector', ThreadPositionService.elementToFocus(position, $scope.discussion))

    $scope.setDefaults()
    $scope.init()

    return
