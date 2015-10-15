angular.module('loomioApp').factory 'ModalService', ($modal, $rootScope) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}) ->
      $rootScope.$broadcast 'modalOpened'
      if currentModal?
        currentModal.close()
      currentModal = $modal.open
        templateUrl: modal.templateUrl
        controller:  modal.controller
        resolve:     resolve
        size:        (modal.size || '')
