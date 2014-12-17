angular.module('loomioApp').controller 'GroupController', ($scope, group, Records, MessageChannelService, UserAuthService) ->
  console.log 'group', group
  $scope.group = group

  MessageChannelService.subscribeTo("/group-#{group.key}")

  $scope.isMember = ->
    UserAuthService.currentUser.membershipFor($scope.group)?

  $scope.joinGroup = ->
    Records.memberships.create(group_id: $scope.group.id)

  $scope.canJoin = ->
    !$scope.isMember() && $scope.group.membershipGrantedUpon == "request"

  $scope.canRequestMembership = ->
    !$scope.isMember() && $scope.group.membershipGrantedUpon == "approval"

  $scope.showNonMemberOptions = ->
    !$scope.isMember() && ($scope.canJoin() || $scope.canRequestMembership())
