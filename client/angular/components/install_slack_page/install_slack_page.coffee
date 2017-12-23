Session = require 'shared/services/session.coffee'

angular.module('loomioApp').controller 'InstallSlackPageController', ($rootScope, ModalService, InstallSlackModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'installSlackPage' })
  ModalService.open(InstallSlackModal, group: (-> null), preventClose: (-> true)) if Session.user().identityFor('slack')

  return
