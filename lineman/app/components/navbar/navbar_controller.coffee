angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, Records, UserAuthService, DiscussionFormService) ->

  $scope.openDiscussionForm = ->
    DiscussionFormService.openNewDiscussionModal()

  $scope.currentUser = ->
    window.Loomio.currentUser

  return