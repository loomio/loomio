angular.module('loomioApp').controller 'InboxPageController', ($scope, $rootScope, Records, CurrentUser, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', {page: 'inboxPage'})
  $rootScope.$broadcast('setTitle', 'Inbox')

  @threadLimit = 5

  @groups = ->
    CurrentUser.parentGroups()

  @init = =>
    _.each @groups(), (group) =>
      @["group#{group.id}"] = ThreadQueryService.groupQuery(group)
    @baseQuery = ThreadQueryService.filterQuery('show_unread')
  @init()
  $scope.$on 'currentUserMembershipsLoaded', @init

  @queryFor = (group) ->
    @["group#{group.id}"]

  @moreForThisGroup = (group) ->
    @queryFor(group).length() > @threadLimit

  return
