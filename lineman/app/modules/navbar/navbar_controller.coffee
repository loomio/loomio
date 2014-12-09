angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, Records, UserAuthService) ->
  $scope.showInbox = false

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal()

  $scope.toggleInbox = (open) -> $scope.showInbox = open

  $scope.currentUser = ->
    UserAuthService.currentUser

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
