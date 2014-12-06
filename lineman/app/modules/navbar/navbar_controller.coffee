angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, Records, UserAuthService) ->
  $scope.showInbox = false

  $scope.openDiscussionForm = ->
    modalInstance = $modal.open
      templateUrl: 'modules/discussion_page/discussion_form'
      controller: 'DiscussionFormController'
      resolve:
        discussion: -> Records.discussions.initialize()

  $scope.toggleInbox = (open) -> $scope.showInbox = open

  $scope.currentUser = ->
    UserAuthService.currentUser

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
