angular.module('loomioApp').controller 'InboxPageController', ($scope, $rootScope, Records, CurrentUser, AppConfig, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', {page: 'inboxPage'})
  $rootScope.$broadcast('setTitle', 'Inbox')
  $rootScope.$broadcast('analyticsClearGroup')

  @threadLimit = 50
  @views =
    groups: {}

  @loading = -> !(AppConfig.inboxLoaded and AppConfig.membershipsLoaded)

  @groups = ->
    CurrentUser.parentGroups()

  @init = =>
    return if @loading()
    _.each @groups(), (group) =>
      @views.groups[group.key] = ThreadQueryService.groupQuery(group)
  $scope.$on 'currentUserMembershipsLoaded', @init
  $scope.$on 'currentUserInboxLoaded', @init
  @init()

  @hasThreads = ->
    ThreadQueryService.filterQuery('show_unread', queryType: 'inbox').any()

  @moreForThisGroup = (group) ->
    @views.groups[group.key].length() > @threadLimit

  return
