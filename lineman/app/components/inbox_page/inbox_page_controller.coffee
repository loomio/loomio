angular.module('loomioApp').controller 'InboxPageController', ($rootScope, Records, CurrentUser, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', 'inboxPage')
  $rootScope.$broadcast('setTitle', 'Inbox')

  @threadLimit = 5

  _.each CurrentUser.parentGroups(), (group) =>
    @["group#{group.id}"] = ThreadQueryService.groupQuery(group)

  @queryFor = (group) -> @["group#{group.id}"]

  @groups           = -> CurrentUser.parentGroups()
  @groupName        = (group) -> group.name
  @moreForThisGroup = (group) -> @queryFor(group).length() > @threadLimit

  return