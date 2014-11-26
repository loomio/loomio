angular.module('loomioApp').controller 'NavbarNotificationsController', ($scope, NotificationService, UserAuthService) ->
  NotificationService.fetch {}

  $scope.notifications = ->
    UserAuthService.currentUser.notifications()
