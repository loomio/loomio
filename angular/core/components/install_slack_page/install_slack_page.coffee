angular.module('loomioApp').controller 'InstallSlackPageController', ($rootScope, ModalService, InstallSlackModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'installSlackPage' })
  ModalService.open InstallSlackModal

  return
