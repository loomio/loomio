angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, DiscussionModel, UserAuthService) ->
  $scope.userLoggedIn = ->
    UserAuthService.currentUser?

  $scope.showInbox = false
  $scope.showSearch = false
  $scope.showNotifications = false

  $scope.openDiscussionForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/discussion_form.html'
      controller: 'DiscussionFormController'
      resolve:
        discussion: -> new DiscussionModel

  $scope.toggleInbox =         (open) -> $scope.showInbox = open
  $scope.toggleSearch =        (open) -> 
    $scope.showSearch = open
    console.log('Toggle search: ' + open)
  $scope.toggleNotifications = (open) -> $scope.showNotifications = open 