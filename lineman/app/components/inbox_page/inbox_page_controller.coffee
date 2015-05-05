angular.module('loomioApp').controller 'InboxPageController', ($rootScope, Records, CurrentUser, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', 'inboxPage')
  $rootScope.$broadcast('setTitle', 'Inbox')

  @threadLimit = 5

  @inboxGroups = ->
    _.filter CurrentUser.groups(), (group) -> group.isParent()

  _.map @inboxGroups(), (group) =>
    @["group#{group.id}"] = ThreadQueryService.groupQuery(group)
  @queryFor = (group) -> @["group#{group.id}"]

  @groupName        = (group) -> group.name
  @moreForThisGroup = (group) -> @queryFor(group).length() > @threadLimit

  Records.discussions.fetchInbox()
  Records.votes.fetchMyRecentVotes()

  return