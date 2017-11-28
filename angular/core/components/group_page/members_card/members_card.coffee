angular.module('loomioApp').directive 'membersCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/members_card/members_card.html'
  controller: ($scope, Records, AbilityService, ModalService, InvitationModal) ->
    $scope.canViewMemberships = ->
      AbilityService.canViewMemberships($scope.group)

    $scope.canAddMembers = ->
      AbilityService.canAddMembers($scope.group)

    $scope.isAdmin = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.memberIsAdmin = (member) ->
      $scope.group.membershipFor(member).admin

    $scope.showMembersPlaceholder = ->
      AbilityService.canAdministerGroup($scope.group) and $scope.group.memberships().length <= 1

    $scope.invitePeople = ->
      ModalService.open InvitationModal, group: -> $scope.group

    if $scope.canViewMemberships()
      Records.memberships.fetchByGroup $scope.group.key, per: 10
