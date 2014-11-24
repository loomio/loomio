angular.module('loomioApp').controller 'NavbarNotificationsController', ($scope, NotificationService, UserAuthService) ->
  currentUser = UserAuthService.currentUser

  $scope.currentNotifications = ->
    currentUser.notifications() if currentUser?

  nextPage = 1
  busy = false
  $scope.lastPage = false

  $scope.getNextPage = ->
    return false if busy or $scope.lastPage
    busy = true
    NotificationService.fetch {page: nextPage}, (notifications) ->
      $scope.lastPage = true if notifications.length == 0
      nextPage = nextPage + 1
      busy = false

  $scope.getNextPage()