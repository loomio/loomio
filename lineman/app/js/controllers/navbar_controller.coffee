angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, DiscussionModel, UserAuthService) ->

  $scope.showInbox = false

  $scope.openDiscussionForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/discussion_form.html'
      controller: 'DiscussionFormController'
      resolve:
        discussion: -> new DiscussionModel

  $scope.toggleInbox =         (open) -> $scope.showInbox = open

  $scope.currentUser = ->
    UserAuthService.currentUser