angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, Records, UserAuthService) ->
  $scope.showInbox = false

  $scope.openDiscussionForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/discussion_form.html'
      controller: 'DiscussionFormController'
      resolve:
        discussion: -> Records.discussions.new

  $scope.toggleInbox =         (open) -> $scope.showInbox = open

  $scope.currentUser = ->
    UserAuthService.currentUser

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned