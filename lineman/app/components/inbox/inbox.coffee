angular.module('loomioApp').directive 'inbox', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/inbox/inbox.html'
  replace: true
  controller: ($scope, InboxService) ->
    # build a loki view for each of these modes.
    # maybe within the service
    InboxService.fetchRecords().then (data) ->
      $scope.unreadThreads = InboxService.unreadThreads()
      $scope.currentThreads = InboxService.currentThreads()

    $scope.unreadThreads = InboxService.unreadThreads()
    $scope.currentThreads = InboxService.currentThreads()

    #Either display collated by group or by latest activity.

    # inbox should show discussions which are not muted
    # 1 mode is unread with activity within some timeframe
    # 1 mode is recently acitve
    # 1 mode is current motions
