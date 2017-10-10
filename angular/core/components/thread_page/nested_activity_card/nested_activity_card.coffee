angular.module('loomioApp').directive 'nestedActivityCard', (ThreadWindow, $mdDialog, $timeout, $window, $location, AbilityService)->
  scope: {discussion: '=', loading: '=', activeCommentId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/nested_activity_card/nested_activity_card.html'
  replace: true
  controller: ($scope) ->
    $scope.$on 'fetchRecordsForPrint', (event, options = {}) ->
      $scope.tw.loadAll().then ->
        $mdDialog.cancel()
        $timeout -> $window.print()


    $scope.discussion.markAsSeen()

    # loadFrom, scrollTo:
    $scope.initialSequenceId = ->
      #load from: from, scrollTo: from
      return $location.search().from                  if $location.search().from      # respond to ?from parameter

      # load from 1, scroll to nothing
      return $scope.discussion.firstSequenceId        if !AbilityService.isLoggedIn() # show beginning of discussion for logged out users

      # load from 2 back, sroll to latestActivity
      return $scope.discussion.lastReadSequenceId - 2 if $scope.discussion.isUnread() # show newest unread content for logged in users

      # load last page, scroll to end
      return $scope.discussion.lastSequenceId - $scope.tw.per + 2                     # show latest content if the discussion has been read


    $scope.visible = (event) ->
      $scope.tw.isLastInWindow(event) && $scope.tw.loadNext()

    $scope.tw = new ThreadWindow(discussion: $scope.discussion)
    $scope.tw.reset($scope.initialSequenceId())
    $scope.tw.loadNext().then -> $scope.$emit('threadPageEventsLoaded')


    return
