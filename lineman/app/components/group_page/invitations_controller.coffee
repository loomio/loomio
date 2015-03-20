angular.module('loomioApp').controller 'InvitationsController', ($scope, $modal) ->
  $scope.openForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/components/group_page/invitation_modal.html'
      controller: 'InvitationsModalController'
      resolve:
        group: -> $scope.group

