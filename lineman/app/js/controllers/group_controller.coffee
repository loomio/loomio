angular.module('loomioApp').controller 'GroupController', ($scope, group, MessageChannelService, MembershipService, UserAuthService, Records) ->
  $scope.group = group

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/group-#{group.id}", onMessageReceived)

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned

  $scope.isMember = ->
    UserAuthService.currentUser.membershipFor($scope.group)?

  $scope.canJoin = ->
    !$scope.isMember() && $scope.group.membershipGrantedUpon == "request"

  $scope.canRequestMembership = ->
    !$scope.isMember() && $scope.group.membershipGrantedUpon == "approval"

  $scope.joinGroup = ->
    membership = Records.memberships.new(group_id: $scope.group.id)
    MembershipService.create(membership)

  $scope.showNonMemberOptions = ->
    !$scope.isMember() && ($scope.canJoin() || $scope.canRequestMembership())