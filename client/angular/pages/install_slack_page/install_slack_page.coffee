Session      = require 'shared/services/session'
EventBus     = require 'shared/services/event_bus'
ModalService = require 'shared/services/modal_service'

$controller = ($rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'installSlackPage' }
  ModalService.open('InstallSlackModal', group: (-> null), preventClose: (-> true)) if Session.user().identityFor('slack')

  return

$controller.$inject = ['$rootScope']
angular.module('loomioApp').controller 'InstallSlackPageController', $controller
