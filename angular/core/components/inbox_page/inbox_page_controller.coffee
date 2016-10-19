angular.module('loomioApp').controller 'InboxPageController', ($scope, $rootScope, Records, Session, AppConfig, LoadingService, ThreadQueryService, ModalService, GroupForm) ->
  $rootScope.$broadcast('currentComponent', {page: 'inboxPage'})
  $rootScope.$broadcast('setTitle', 'Inbox')
  $rootScope.$broadcast('analyticsClearGroup')

  filters = ['only_threads_in_my_groups', 'show_unread', 'show_not_muted']
  @threadLimit = 50
  @views =
    groups: {}

  @groups = ->
    _.flatten [Session.user().parentGroups(), Session.user().orphanSubgroups()]

  @init = =>
    _.each @groups(), (group) =>
      @views.groups[group.key] = ThreadQueryService.groupQuery(group, filter: filters)
  $scope.$on 'currentUserMembershipsLoaded', @init
  @init()

  @hasThreads = ->
    ThreadQueryService.filterQuery(filters, queryType: 'inbox').any()

  @moreForThisGroup = (group) ->
    @views.groups[group.key].length() > @threadLimit

  @noGroups = ->
    !Session.user().hasAnyGroups()

  @startGroup = ->
    ModalService.open GroupForm, group: -> Records.groups.build()

  return
