angular.module('loomioApp').controller 'GroupPageController', ($rootScope, $routeParams, Records, CurrentUser, MessageChannelService, AbilityService) ->
  $rootScope.$broadcast 'currentComponent', {page: 'groupPage'}

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    $rootScope.$broadcast 'currentComponent', { page: 'groupPage' }
    $rootScope.$broadcast 'viewingGroup', @group
    $rootScope.$broadcast 'setTitle', @group.fullName
    $rootScope.$broadcast 'analyticsSetGroup', @group
    MessageChannelService.subscribeToGroup(@group)
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  @showDescriptionPlaceholder = ->
    AbilityService.canAdministerGroup(@group) and !@group.description

  @canManageMembershipRequests = ->
    AbilityService.canManageMembershipRequests(@group)

  return
