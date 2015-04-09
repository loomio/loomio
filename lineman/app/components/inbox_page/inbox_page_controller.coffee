angular.module('loomioApp').controller 'InboxPageController', ($rootScope, Records, CurrentUser, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'inboxPage')
  $rootScope.$broadcast('setTitle', 'Inbox')

  @threadLimit = 5

  @inboxGroups = ->
    _.filter CurrentUser.groups(), (group) -> group.isParent()

  @allInboxThreads = (group) ->
    _.filter Records.discussions
                    .forInbox(group)
                    .simplesort('lastActivityAt', true)
                    .data(), (thread) -> thread.isUnread()

  @inboxThreads = (group) ->
    _.take @allInboxThreads(group), @threadLimit

  @groupName        = (group) -> group.name
  @anyForThisGroup  = (group) -> @allInboxThreads(group).length > 0
  @moreForThisGroup = (group) -> @allInboxThreads(group).length > @threadLimit

  Records.votes.fetchMyRecentVotes()

  return