angular.module('loomioApp').directive 'notifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/notifications/notifications.html'
  replace: true
  controller: ($scope, $rootScope, Records, AppConfig) ->

    kinds = [
      'comment_liked',
      'motion_closing_soon',
      'comment_replied_to',
      'user_mentioned',
      'membership_requested',
      'membership_request_approved',
      'user_added_to_group',
      'motion_closed',
      'motion_closing_soon',
      'motion_outcome_created',
      'invitation_accepted',
      'new_coordinator',
      'poll_created',
      'poll_closing_soon',
      'poll_edited',
      'poll_expired',
      'outcome_created'
    ]

    notificationsView = Records.notifications.collection.addDynamicView("notifications")
                               .applyFind(kind: { $in: kinds })

    unreadView =        Records.notifications.collection.addDynamicView("unread")
                               .applyFind(kind: { $in: kinds })
                               .applyFind(viewed: { $ne: true })

    $scope.notifications = -> notificationsView.data()

    $scope.broadcastThreadEvent = (notification) ->
      # $rootScope.$broadcast 'threadPageEventsLoaded', notification.event()

    $scope.toggled = (open) ->
      Records.notifications.viewed() if open

    $scope.unreadCount = =>
      unreadView.data().length

    $scope.hasUnread = =>
      $scope.unreadCount() > 0

    return
