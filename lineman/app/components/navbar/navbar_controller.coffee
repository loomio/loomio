angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, Records, UserAuthService, DiscussionFormService) ->
  $scope.showInbox = false

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal()

  $scope.toggleInbox = (open) -> $scope.showInbox = open

  $scope.currentUser = ->
    window.Loomio.currentUser
