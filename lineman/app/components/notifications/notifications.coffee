angular.module('loomioApp').directive 'notifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/notifications/notifications.html'
  replace: true
  controller: ($scope, UserAuthService, Records, CurrentUser, MessageChannelService) ->

    MessageChannelService.subscribeToNotifications()
    Records.notifications.fetchMyNotifications()

    kinds = [
      'comment_liked',
      'motion_closing_soon',
      'comment_replied_to',
      'user_mentioned',
      'membership_requested',
      'membership_request_approved',
      'user_added_to_group',
      'motion_closing_soon',
      'motion_outcome_created'
    ]

    notificationsView = Records.notifications.collection.addDynamicView("CurrentUser")
    notificationsView.applySimpleSort('createdAt', true)
    notificationsView.applyWhere (notification) ->
      _.contains(kinds, notification.event().kind)

    $scope.toggled = (open) ->
      if open
        Records.notifications.viewed()

    $scope.count = =>
      notificationsView.data().length

    $scope.unread = ->
      $scope.unreadCount() > 0

    $scope.unreadCount = =>
      _.filter($scope.notifications(), (n) -> !n.viewed).length

    $scope.notifications = =>
      notificationsView.data()

    return
