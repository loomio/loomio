Session      = require 'shared/services/session.coffee'
ModalService = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').controller 'InstallSlackPageController', ($rootScope) ->
  $rootScope.$broadcast('currentComponent', { page: 'installSlackPage' })
  ModalService.open('InstallSlackModal', group: (-> null), preventClose: (-> true)) if Session.user().identityFor('slack')

  return
