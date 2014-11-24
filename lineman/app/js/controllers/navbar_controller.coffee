angular.module('loomioApp').controller 'NavbarController', ($scope, $modal, DiscussionModel) ->
  $scope.inboxIsOpen = false

  $scope.toggled = (open) ->
    $scope.inboxIsOpen = open

  $scope.openDiscussionForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/discussion_form.html'
      controller: 'DiscussionFormController'
      resolve:
        discussion: -> new DiscussionModel