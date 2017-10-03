angular.module('loomioApp').controller 'InboxPageController', ($scope, $rootScope, Records, Session, AppConfig, LoadingService, InboxService, ModalService, GroupModal) ->
  $rootScope.$broadcast('currentComponent', {titleKey: 'inbox_page.unread_threads' ,page: 'inboxPage'})
  $rootScope.$broadcast('setTitle', 'Inbox')
  $rootScope.$broadcast('analyticsClearGroup')

  @threadLimit = 50
  @views = InboxService.queryByGroup()

  @groups = ->
    Records.groups.find(_.keys(@views))

  @hasThreads = ->
    InboxService.unreadCount() > 0

  @noGroups = ->
    !Session.user().hasAnyGroups()

  @startGroup = ->
    ModalService.open GroupModal, group: -> Records.groups.build()

  return
