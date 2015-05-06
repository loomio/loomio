angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, CurrentUser, Records, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'groupsPage')
  $rootScope.$broadcast('setTitle', 'Groups')

  @groups = -> CurrentUser.parentGroups()
  @groupName = (group) -> group.name

  return
