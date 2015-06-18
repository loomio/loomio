angular.module('loomioApp').directive 'membersCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/members_card/members_card.html'
  replace: true
  controller: ($scope, Records, CurrentUser, ModalService, InvitationForm) ->
    Records.memberships.fetchByGroup $scope.group

    $scope.canAddMembers = ->
      $scope.group.membersCanAddMembers or CurrentUser.isAdminOf($scope.group)

    $scope.isAdminOf = ->
      CurrentUser.isAdminOf($scope.group)

    $scope.showMembersPlaceholder = ->
      CurrentUser.isAdminOf($scope.group) and $scope.group.memberships().length <= 1

    $scope.invitePeople = ->
      ModalService.open InvitationForm, group: -> $scope.group
