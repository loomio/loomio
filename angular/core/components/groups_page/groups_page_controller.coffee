angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, Session, Records, LoadingService, GroupForm, ModalService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  @parentGroups = =>
    _.unique _.compact _.map Session.user().memberships(), (membership) =>
      if membership.group().isParent()
        membership.group()
      else if !Session.user().isMemberOf(membership.group().parent())
        membership.group().parent()

  @startGroup = ->
    ModalService.open GroupForm, group: -> Records.groups.build()

  return
