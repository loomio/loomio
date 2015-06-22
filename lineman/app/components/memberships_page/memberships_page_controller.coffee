angular.module('loomioApp').controller 'MembershipsPageController', ($routeParams, $rootScope, Records, LoadingService, ModalService, InvitationForm, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'membershipsPage'})

  @init = (group) =>
    if group and !@group?
      @group      = group
      Records.memberships.fetchByGroup(@group.key)

  @init Records.discussions.find $routeParams.key
  Records.groups.findOrFetchByKey($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error, group)

  @canAdministerGroup = ->
    AbilityService.canAdministerGroup(@group)

  @canAddMembers = ->
    AbilityService.canAddMembers(@group)

  @canRemoveMembership = (membership) ->
    AbilityService.canRemoveMembership(membership)

  @canToggleAdmin = (membership) ->
    @canAdministerGroup(membership) and
    (!membership.admin or @canRemoveMembership(membership))

  @toggleAdmin = (membership) ->
    method = if membership.admin then 'makeAdmin' else 'removeAdmin'
    Records.memberships[method](membership)

  @invitePeople = ->
    ModalService.open InvitationForm, group: => @group

  return
