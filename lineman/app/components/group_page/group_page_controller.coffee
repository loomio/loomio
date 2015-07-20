angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, Records, CurrentUser, ScrollService, ModalService, MessageChannelService, GroupWelcomeModal, AbilityService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  $rootScope.$on 'newGroupCreated', ->
    ModalService.open GroupWelcomeModal

  Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName()
    $rootScope.$broadcast 'analyticsSetGroup', @group
    MessageChannelService.subscribeTo("/group-#{@group.key}")
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @isMember = ->
    CurrentUser.membershipFor(@group)?

  @showDescriptionPlaceholder = ->
    AbilityService.canAdministerGroup(@group) and !@group.description

  @canManageMembershipRequests = ->
    AbilityService.canManageMembershipRequests(@group)

  return
