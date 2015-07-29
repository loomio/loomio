angular.module('loomioApp').controller 'AdminMembershipsPanelController', ($scope, CurrentUser, AbilityService, ModalService, RemoveMembershipForm, InvitationForm) ->

  $scope.canRemoveMembership = (membership) ->
    AbilityService.canRemoveMembership(membership)

  $scope.canToggleAdmin = (membership) ->
    AbilityService.canAdministerGroup($scope.group) and
    (!membership.admin or $scope.canRemoveMembership(membership))

  $scope.toggleAdmin = (membership) ->
    method = if membership.admin then 'makeAdmin' else 'removeAdmin'
    Records.memberships[method](membership).then ->
      FlashService.success "memberships_page.messages.#{_.snakeCase method}_success", name: membership.userName()

  $scope.openRemoveForm = (membership) ->
    ModalService.open RemoveMembershipForm, membership: -> membership

  $scope.canAddMembers = ->
    AbilityService.canAddMembers($scope.group)

  $scope.invitePeople = ->
    ModalService.open InvitationForm, group: => $scope.group
