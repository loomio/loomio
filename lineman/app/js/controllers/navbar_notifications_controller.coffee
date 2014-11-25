angular.module('loomioApp').controller 'NavbarNotificationsController', ($scope, NotificationService, UserAuthService, RecordStoreService) ->
  NotificationService.fetch {}

  $scope.notifications = ->
    RecordStoreService.get 'notifications', (notification) ->
      _.contains ['comment_liked'], notification.event().kind

