angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, Session, Records, LoadingService, GroupForm, ModalService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  @parentGroups = =>
    Session.user().topLevelGroups()

  @startGroup = ->
    ModalService.open GroupForm, group: -> Records.groups.build()

  return
