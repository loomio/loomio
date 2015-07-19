angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, CurrentUser, Records, LoadingService, StartGroupForm, ModalService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  @groups = -> CurrentUser.parentGroups()

  @startGroup = ->
    ModalService.open StartGroupForm, group: -> Records.groups.build()

  return
