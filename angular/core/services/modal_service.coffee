angular.module('loomioApp').factory 'ModalService', ($uibModal, $rootScope, AhoyService) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}) ->
      $rootScope.$broadcast 'modalOpened', modal
      if currentModal?
        currentModal.close()
      currentModal = $uibModal.open
        templateUrl: modal.templateUrl
        controller:  modal.controller
        resolve:     resolve
        size:        (modal.size || '')
        backdrop:    'static'
