angular.module('loomioApp').controller 'GroupController', ($scope, $document, $timeout, group, Records, MessageChannelService, UserAuthService) ->

  $timeout ->
    console.log 'should have scrolled to the top at:', moment().calendar()
    $document.scrollTop(0)
  ,
    200

  $scope.group = group

  MessageChannelService.subscribeTo("/group-#{group.key}")

  $scope.isMember = ->
    window.Loomio.currentUser.membershipFor($scope.group)?

  $scope.joinGroup = ->
    Records.memberships.create(group_id: $scope.group.id)
