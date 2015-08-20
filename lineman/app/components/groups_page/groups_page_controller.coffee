angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, CurrentUser, Records, LoadingService, StartGroupForm, ModalService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  console.log 'currentuser memberships:', CurrentUser.memberships()
  @parentGroups = =>
    _.unique _.map CurrentUser.memberships(), (membership) =>
      if membership.group().isParent()
        membership.group()
      else if !CurrentUser.isMemberOf(membership.group().parent())
        membership.group().parent()

  @startGroup = ->
    ModalService.open StartGroupForm, group: -> Records.groups.build()

  return
