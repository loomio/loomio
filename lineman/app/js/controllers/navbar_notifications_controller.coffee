angular.module('loomioApp').controller 'NavbarNotificationsController', ($scope, NotificationService, UserAuthService, MainRecordStore) ->
  NotificationService.fetch {}

  $scope.notifications = ->
    MainRecordStore.notifications.get (notification) ->
      _.contains ['comment_liked'], notification.event().kind

