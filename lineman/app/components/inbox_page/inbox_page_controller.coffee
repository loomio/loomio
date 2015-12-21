angular.module('loomioApp').controller 'InboxPageController', ($scope, $rootScope, Records, CurrentUser, AppConfig, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', {page: 'inboxPage'})
  $rootScope.$broadcast('setTitle', 'Inbox')
  $rootScope.$broadcast('analyticsClearGroup')

  filters = ['only_threads_in_my_groups', 'show_unread', 'show_not_muted']
  @threadLimit = 50
  @views =
    groups: {}

  @loading = -> !(AppConfig.inboxLoaded and AppConfig.membershipsLoaded)

  @groups = ->
    _.flatten [CurrentUser.parentGroups(), CurrentUser.orphanSubgroups()]

  @init = =>
    return if @loading()
    _.each @groups(), (group) =>
      @views.groups[group.key] = ThreadQueryService.groupQuery(group, filter: filters)
  $scope.$on 'currentUserMembershipsLoaded', @init
  $scope.$on 'currentUserInboxLoaded', @init
  @init()

  @hasThreads = ->
    ThreadQueryService.filterQuery(filters, queryType: 'inbox').any()

  @moreForThisGroup = (group) ->
    @views.groups[group.key].length() > @threadLimit

  return
