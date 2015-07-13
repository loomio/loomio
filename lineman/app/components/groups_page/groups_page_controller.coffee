angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, CurrentUser, Records, LoadingService) ->
  $rootScope.$broadcast('currentComponent', {page: 'groupsPage'})
  $rootScope.$broadcast('setTitle', 'Groups')

  @groups = -> CurrentUser.parentGroups()

  return
