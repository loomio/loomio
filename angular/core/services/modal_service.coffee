angular.module('loomioApp').factory 'ModalService', ($mdDialog, $rootScope) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}, opts = {}) ->
      $rootScope.$broadcast 'modalOpened', modal
      $scope = $rootScope.$new(true)
      $scope.$close = $mdDialog.cancel
      resolve.preventClose = resolve.preventClose or (-> false)
      modalType = opts.type || 'alert'
      currentModal = $mdDialog[modalType](
        scope:       $scope
        templateUrl: modal.templateUrl
        controller:  modal.controller
        resolve:     resolve
        size:        (modal.size || '')
        backdrop:    'static'
        escapeToClose: !resolve.preventClose()
      )
      $mdDialog.show(currentModal).finally -> currentModal = undefined
