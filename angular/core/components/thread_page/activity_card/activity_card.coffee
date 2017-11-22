angular.module('loomioApp').directive 'activityCard', (ChronologicalEventWindow, NestedEventWindow, RecordLoader, $mdDialog, $timeout, $window, AppConfig, ThreadPositionService)->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  controller: ($scope) ->
    $scope.setDefaults = ->
      $scope.per = AppConfig.pageSize.threadItems
      $scope.renderMode = "chronological"
      $scope.position = $scope.positionForSelect()

    $scope.positionForSelect = ->
      if _.include(['requested', 'context'], $scope.initialPosition())
        "beginning"
      else
        $scope.initialPosition()

    $scope.initialPosition = ->
      switch
        when $scope.discussion.requestedSequenceId
          "requested"
        when (!$scope.discussion.lastReadAt) || $scope.discussion.itemsCount == 0
          'context'
        when $scope.discussion.readItemsCount() == 0
          'beginning'
        when $scope.discussion.isUnread()
          'unread'
        else
          'latest'

    $scope.initialSequenceId = (position) ->
      switch position
        when "requested"            then $scope.discussion.requestedSequenceId
        when "beginning", "context" then $scope.discussion.firstSequenceId()
        when "unread"               then $scope.discussion.firstUnreadSequenceId()
        when "latest"               then $scope.discussion.lastSequenceId() - $scope.per + 2

    $scope.elementToFocus = (position) ->
      switch position
        when "context"   then ".context-panel h1"
        when "requested" then "#sequence-#{$scope.discussion.requestedSequenceId}"
        when "beginning" then "#sequence-#{$scope.discussion.firstSequenceId()}"
        when "unread"    then "#sequence-#{$scope.discussion.firstUnreadSequenceId()}"
        when "latest"    then "#sequence-#{$scope.discussion.lastSequenceId()}"

    $scope.$on 'fetchRecordsForPrint', (event, options = {}) ->
      $scope.eventWindow.loadAll().then ->
        $mdDialog.cancel()
        $timeout -> $window.print()

    $scope.init = (position = $scope.initialPosition()) ->
      $scope.loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: $scope.discussion.id
          order: 'sequence_id'
          from: $scope.initialSequenceId(position)
          per: $scope.per

      $scope.loader.loadMore().then ->
        if $scope.renderMode == "chronological"
          $scope.eventWindow = new ChronologicalEventWindow
            discussion: $scope.discussion
            initialSequenceId: $scope.initialSequenceId(position)
            per: $scope.per
        else
          $scope.eventWindow = new NestedEventWindow
            discussion: $scope.discussion
            parentEvent: $scope.discussion.createdEvent()
            initialSequenceId: $scope.initialSequenceId(position)
            per: $scope.per

        $scope.$emit('threadPageScrollToSelector', $scope.elementToFocus(position))

    $scope.setDefaults()
    $scope.init()

    return
