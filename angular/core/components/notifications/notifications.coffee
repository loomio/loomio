angular.module('loomioApp').directive 'notifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/notifications/notifications.html'
  replace: true
  controller: ($scope, Records, AppConfig) ->

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
    eventFilter = (notification) -> _.contains kinds, notification.event().kind

    notificationsView = Records.notifications.collection.addDynamicView("notifications")
                               .applyWhere(eventFilter)
    $scope.notifications = -> notificationsView.data()

    unreadView =        Records.notifications.collection.addDynamicView("unread")
                               .applyWhere(eventFilter)
                               .applyFind(viewed: { $ne: true })
    $scope.unreadNotifications = -> unreadView.data()

    $scope.loading = ->
      !AppConfig.notificationsLoaded

    $scope.toggled = (open) ->
      Records.notifications.viewed() if open

    $scope.unreadCount = =>
      $scope.unreadNotifications().length

    $scope.hasUnread = =>
      $scope.unreadCount() > 0

    return
