angular.module('loomioApp').controller 'GroupMembersController', ($scope, $modal, MembershipService) ->
  MembershipService.fetchByGroup $scope.group.id

  $scope.openInvitationsForm = ->
    $modal.open
      templateUrl: 'generated/templates/group_invitations_form.html'
      controller: 'GroupInvitationsFormController'
      resolve:
        group: -> $scope.group
