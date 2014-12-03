angular.module('loomioApp').controller 'InboxController', ($scope, Records, UserAuthService) ->
  $scope.currentUser = UserAuthService.currentUser

  Records.discussions.fetchInbox()

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned

  $scope.openInbox = ->
    UserAuthService.inboxPinned = true
    console.log UserAuthService.inboxPinned

  $scope.closeInbox = ->
    UserAuthService.inboxPinned = false
    console.log UserAuthService.inboxPinned

