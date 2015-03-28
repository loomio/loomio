angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, Records, CurrentUser, DiscussionFormService) ->

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal()

  $scope.currentUser = ->
    CurrentUser

  return