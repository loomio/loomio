angular.module('loomioApp').controller 'GroupsPageController', ($rootScope, Session) ->
  $rootScope.$broadcast('currentComponent', { page: 'groupsPage'})

  @groups = =>
    Session.user().formalGroups()

  return
