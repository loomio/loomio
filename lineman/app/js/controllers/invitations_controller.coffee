angular.module('loomioApp').controller 'InvitationController', ($scope, $modal) ->
  $scope.openForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/invitation_modal.html'
      controller: 'InvitationsModalController'
