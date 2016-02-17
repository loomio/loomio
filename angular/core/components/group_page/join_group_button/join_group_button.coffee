angular.module('loomioApp').directive 'joinGroupButton', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/join_group_button/join_group_button.html'
  replace: true
  controller: ($scope, AbilityService, ModalService, CurrentUser, Records, FlashService, MembershipRequestForm) ->
    Records.membershipRequests.fetchMyPendingByGroup($scope.group.key)

    $scope.isMember = ->
      CurrentUser.membershipFor($scope.group)?

    $scope.canJoinGroup = ->
      AbilityService.canJoinGroup($scope.group)

    $scope.canRequestMembership = ->
      AbilityService.canRequestMembership($scope.group)

    $scope.joinGroup = ->
      Records.memberships.joinGroup($scope.group).then ->
        FlashService.success('join_group_button.messages.joined_group', group: $scope.group.fullName)

    $scope.requestToJoinGroup = ->
      ModalService.open MembershipRequestForm, group: -> $scope.group

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
