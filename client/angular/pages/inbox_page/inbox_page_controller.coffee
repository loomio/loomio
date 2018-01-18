AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
InboxService   = require 'shared/services/inbox_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

$controller = ($scope, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', {titleKey: 'inbox_page.unread_threads' ,page: 'inboxPage'}
  InboxService.load()

  @threadLimit = 50
  @views = InboxService.queryByGroup()

  @loading = ->
    !InboxService.loaded

  @groups = ->
    Records.groups.find(_.keys(@views))

  @hasThreads = ->
    InboxService.unreadCount() > 0

  @noGroups = ->
    !Session.user().hasAnyGroups()

  @startGroup = ->
    ModalService.open 'GroupModal', group: -> Records.groups.build()

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'InboxPageController', $controller
