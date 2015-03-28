angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, $document, $timeout, Records, MessageChannelService, CurrentUser) ->
  $rootScope.$broadcast('currentComponent', 'groupPage')
  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    MessageChannelService.subscribeTo("/group-#{@group.key}")

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @joinGroup = ->
    Records.memberships.create(group_id: @group.id)
  return
