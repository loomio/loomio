angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, $rootScope, Records, ThreadQueryService) ->
    $scope.$on 'currentComponent', (el, component) ->
      $scope.selected = component

    $scope.unreadThreadCount = ->
      ThreadQueryService.filterQuery('show_unread').length()

    $scope.homePageClicked = ->
      $rootScope.$broadcast 'homePageClicked'

    if !$scope.inboxLoaded
      Records.discussions.fetchInbox(
        from: 0
        per: 100
        since: moment().startOf('day').subtract(6, 'week').toDate() # last 6 weeks of unread content
        timeframe_for: 'last_activity_at'
      ).then ->
        $scope.inboxLoaded = true
