angular.module('loomioApp').controller 'GroupPageController', ($routeParams, $document, $timeout, Records, MessageChannelService, UserAuthService) ->
  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    MessageChannelService.subscribeTo("/group-#{@group.key}")

  @isMember = ->
    window.Loomio.currentUser.membershipFor(@group)?

  @joinGroup = ->
    Records.memberships.create(group_id: @group.id)
  return
