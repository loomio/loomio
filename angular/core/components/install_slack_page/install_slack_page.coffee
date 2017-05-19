angular.module('loomioApp').controller 'InstallSlackPageController', ($rootScope, Session, ModalService, InstallSlackModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'installSlackPage' })
  ModalService.open InstallSlackModal if Session.user().slackIdentity()

  return
