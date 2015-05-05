angular.module('loomioApp').controller 'InboxPageController', ($rootScope, Records, CurrentUser, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', 'inboxPage')
  $rootScope.$broadcast('setTitle', 'Inbox')

  @threadLimit = 5

  @inboxGroups = ->
    _.filter CurrentUser.groups(), (group) -> group.isParent()

  @queryFor = (group) ->
    ThreadQueryService.groupQuery(group)

  @groupName        = (group) -> group.name
  @moreForThisGroup = (group) -> @queryFor(group).threads().length > @threadLimit

  Records.discussions.fetchInbox()
  Records.votes.fetchMyRecentVotes()

  return