angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, CurrentUser, Records, LoadingService, GroupForm, ModalService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  @parentGroups = =>
    _.unique _.compact _.map CurrentUser.memberships(), (membership) =>
      if membership.group().isParent()
        membership.group()
      else if !CurrentUser.isMemberOf(membership.group().parent())
        membership.group().parent()

  @startGroup = ->
    ModalService.open GroupForm, group: -> Records.groups.build()

  return
