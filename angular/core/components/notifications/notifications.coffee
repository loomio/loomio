angular.module('loomioApp').directive 'notifications', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/notifications/notifications.html'
  replace: true
  controller: ($scope, $rootScope, Records, AppConfig) ->

    $scope.toggle = (menu) ->
      if document.querySelector '.md-open-menu-container.md-active .notifications__menu-content'
        $scope.close(menu)
      else
        $scope.open(menu)

    $scope.open = (menu) ->
      menu.open()
      Records.notifications.viewed()
      $rootScope.$broadcast 'notificationsOpen'

    $scope.close = (menu) ->
      menu.close()
      $rootScope.$broadcast 'notificationsClosed'

    notificationsView = Records.notifications.collection.addDynamicView("notifications")
                               .applyFind(kind: { $in: AppConfig.notifications.kinds })

    unreadView =        Records.notifications.collection.addDynamicView("unread")
                               .applyFind(kind: { $in: AppConfig.notifications.kinds })
                               .applyFind(viewed: { $ne: true })

    $scope.notifications = -> notificationsView.data()

    $scope.unreadCount = =>
      unreadView.data().length

    $scope.hasUnread = =>
      $scope.unreadCount() > 0

    return
