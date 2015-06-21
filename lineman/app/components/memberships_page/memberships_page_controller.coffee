angular.module('loomioApp').controller 'MembershipsPageController', ($routeParams, $rootScope, Records, LoadingService, InvitationForm, AbilityService) ->
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

  @toggleMembershipAdmin = (membership) ->
    if membership.admin
      membership.removeAdmin()
    else
      membership.makeAdmin()

  @invitePeople = ->
    ModalService.open InvitationForm, group: => @group

  return
