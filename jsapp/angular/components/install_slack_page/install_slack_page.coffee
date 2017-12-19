angular.module('loomioApp').controller 'InstallSlackPageController', ($rootScope, Session, ModalService, InstallSlackModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'installSlackPage' })
  ModalService.open(InstallSlackModal, group: (-> null), preventClose: (-> true)) if Session.user().identityFor('slack')

  return
