angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, $document, $timeout, Records, MessageChannelService, CurrentUser) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast('setTitle', @group.fullName())
    MessageChannelService.subscribeTo("/group-#{@group.key}")
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @joinGroup = ->
    Records.memberships.initialize(
      group_id: @group.id
      user_id: CurrentUser.id).save()
  
  return
