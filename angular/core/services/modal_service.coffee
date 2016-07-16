angular.module('loomioApp').factory 'ModalService', ($mdDialog, $rootScope) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}, opts = {}) ->
      $rootScope.$broadcast 'modalOpened', modal
      resolve.preventClose = resolve.preventClose or (-> false)
      modalType = opts.type || 'alert'
      currentModal = $mdDialog[modalType](
        templateUrl: modal.templateUrl
        controller:  modal.controller
        resolve:     resolve
        size:        (modal.size || '')
        backdrop:    'static'
        keyboard:    !resolve.preventClose()
      )
      $mdDialog.show(currentModal).finally -> currentModal = undefined
