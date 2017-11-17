angular.module('loomioApp').directive 'activityCard', (ChronologicalEventWindow, NestedEventWindow, RecordLoader, $mdDialog, $timeout, $window, $location, AbilityService)->
  scope: {discussion: '=', loading: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  controller: ($scope) ->
    $scope.$on 'fetchRecordsForPrint', (event, options = {}) ->
      $scope.tw.loadAll().then ->
        $mdDialog.cancel()
        $timeout -> $window.print()

    setDefaults = ->
      $scope.per = 10
      $scope.renderMode = "nested"

      if AbilityService.isLoggedIn()
        switch
          when $scope.discussion.readItemsCount() == 0
            $scope.position = 'beginning'
          when $scope.discussion.isUnread()
            $scope.position = 'unread'
          else
            $scope.position = 'latest'
      else
        $scope.position = 'beginning'

      $scope.position = "specific" if $location.search().from

    $scope.initialSequenceId = ->
      switch $scope.position
        when "specific"  then $location.search().from
        when "beginning" then $scope.discussion.firstSequenceId()
        when "unread"    then $scope.discussion.firstUnreadSequenceId()
        when "latest"    then $scope.discussion.lastSequenceId() - $scope.per + 2

    $scope.init = ->
      $scope.loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: $scope.discussion.id
          order: 'sequence_id'
          from: $scope.initialSequenceId()
          per: $scope.per

      $scope.loader.loadMore().then ->
        if $scope.renderMode == "chronological"
          $scope.eventWindow = new ChronologicalEventWindow
            discussion: $scope.discussion
            initialSequenceId: $scope.initialSequenceId()
            per: $scope.per
        else
          $scope.eventWindow = new NestedEventWindow
            discussion: $scope.discussion
            parentEvent: $scope.discussion.createdEvent()
            initialSequenceId: $scope.initialSequenceId()
            per: $scope.per

        $scope.$emit('threadPageEventsLoaded')

    $scope.discussion.markAsSeen()
    setDefaults()
    $scope.init()

    return
