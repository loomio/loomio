angular.module('loomioApp').directive 'activityCard', (ChronologicalEventWindow, NestedEventWindow, $mdDialog, $timeout, $window, $location, AbilityService)->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope) ->

    $scope.$on 'fetchRecordsForPrint', (event, options = {}) ->
      $scope.tw.loadAll().then ->
        $mdDialog.cancel()
        $timeout -> $window.print()

    $scope.discussion.markAsSeen()

    initialSequenceId = ->
      #load from: from, scrollTo: from
      return $location.search().from                  if $location.search().from      # respond to ?from parameter

      # load from 1, scroll to nothing
      return $scope.discussion.firstSequenceId        if !AbilityService.isLoggedIn() # show beginning of discussion for logged out users

      # load from 2 back, sroll to latestActivity
      return $scope.discussion.lastReadSequenceId - 2 if $scope.discussion.isUnread() # show newest unread content for logged in users

      # load last page, scroll to end
      return $scope.discussion.lastSequenceId - $scope.settings.per + 2                     # show latest content if the discussion has been read

    $scope.settings =
      mode: "chronological"
      position: "oldest"
      orderBy: 'createdAt'
      per: 10

    $scope.settings.initialSequenceId = initialSequenceId()

    $scope.init = ->
      if $scope.settings.mode == "chronological"
        console.log $scope.settings
        $scope.eventWindow = new ChronologicalEventWindow(discussion: $scope.discussion, settings: $scope.settings)
      else
        $scope.eventWindow = new NestedEventWindow(discussion: $scope.discussion, parentEvent: $scope.discussion.createdEvent(), settings: $scope.settings)
      $scope.eventWindow.loadNext().then -> $scope.$emit('threadPageEventsLoaded')

    $scope.init()

    return
