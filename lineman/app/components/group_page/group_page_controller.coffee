angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, $document, $timeout, Records, MessageChannelService, CurrentUser, ScrollService, ModalService, GroupWelcomeModal) ->

  $rootScope.$on 'newGroupCreated', ->
    ModalService.open GroupWelcomeModal

  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName()
    MessageChannelService.subscribeTo("/group-#{@group.key}")
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @joinGroup = ->
    Records.memberships.build(
      group_id: @group.id
      user_id: CurrentUser.id).save()

  @showDescriptionPlaceholder = ->
    CurrentUser.isAdminOf(@group) and !@group.description
  
  return
