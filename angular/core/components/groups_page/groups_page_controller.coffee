angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, User, Records, LoadingService, GroupForm, ModalService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  @parentGroups = =>
    _.unique _.compact _.map User.current().memberships(), (membership) =>
      if membership.group().isParent()
        membership.group()
      else if !User.current().isMemberOf(membership.group().parent())
        membership.group().parent()

  @startGroup = ->
    ModalService.open GroupForm, group: -> Records.groups.build()

  return
