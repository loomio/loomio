angular.module('loomioApp').controller 'GroupMembersController', ($scope, MembershipService) ->
  MembershipService.fetchByGroup $scope.group.id

  $scope.openInvitationsForm = ->
    $modal.open
      templateUrl: 'generated/templates/group_invitations_modal.html'
      controller: 'GroupInvitationsModalController'
      resolve:
        group: -> $scope.group
