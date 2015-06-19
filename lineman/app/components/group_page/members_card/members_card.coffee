angular.module('loomioApp').directive 'membersCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/members_card/members_card.html'
  replace: true
  controller: ($scope, Records, AbilityService, ModalService, InvitationForm) ->
    Records.memberships.fetchByGroup $scope.group

    $scope.canAddMembers = ->
      AbilityService.canAddMembers($scope.group)

    $scope.isAdminOf = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.showMembersPlaceholder = ->
      AbilityService.canAdministerGroup($scope.group) and $scope.group.memberships().length <= 1

    $scope.invitePeople = ->
      ModalService.open InvitationForm, group: -> $scope.group
