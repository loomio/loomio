angular.module('loomioApp').directive 'notifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/notifications/notifications.html'
  replace: true
  controller: ($scope, UserAuthService, Records, CurrentUser) ->

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

    Records.notifications.fetch()

    @notificationsView = Records.notifications.collection.addDynamicView("CurrentUser")
    @notificationsView.applySimpleSort('createdAt', true)
    @notificationsView.applyWhere (notification) ->
      _.contains(kinds, notification.event().kind)

    $scope.toggled = (open) ->
      if open
        CurrentUser.notificationsLastViewedAt = moment()
        Records.notifications.viewed()

    $scope.unread = ->
      $scope.unreadCount() > 0

    $scope.unreadCount = =>
      if CurrentUser.notificationsLastViewedAt?
        _.filter(@notificationsView.data(), (n) -> n.createdAt.isAfter(CurrentUser.notificationsLastViewedAt) ).length
      else
        @notificationsView.data().length

    $scope.notifications = =>
      @notificationsView.data()

    return
