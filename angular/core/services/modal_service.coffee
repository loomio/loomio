angular.module('loomioApp').factory 'ModalService', ($uibModal, $rootScope, AhoyService) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}) ->
      $rootScope.$broadcast 'modalOpened', modal
      currentModal.close() if currentModal?
      resolve.preventClose = resolve.preventClose or (-> false)
      currentModal = $uibModal.open
        templateUrl: modal.templateUrl
        controller:  modal.controller
        resolve:     resolve
        size:        (modal.size || '')
        backdrop:    'static'
        keyboard:    !resolve.preventClose()
