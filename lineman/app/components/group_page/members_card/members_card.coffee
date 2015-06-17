angular.module('loomioApp').directive 'membersCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/members_card/members_card.html'
  replace: true
  controller: ($scope, Records, AbilityService) ->
    Records.memberships.fetchByGroup $scope.group.key

    $scope.canAddMembers = ->
      AbilityService.canAddMembers($scope.group)

    $scope.isAdminOf = ->
      AbilityService.canAdminister($scope.group)

    $scope.showMembersPlaceholder = ->
      AbilityService.canAdminister($scope.group) and $scope.group.memberships().length <= 1

    $scope.invitePeople = ->
      ModalService.open InvitationForm, group: -> $scope.group
