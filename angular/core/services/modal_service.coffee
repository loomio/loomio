angular.module('loomioApp').factory 'ModalService', ($mdDialog, $rootScope, $timeout) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}, opts = {}) ->
      $rootScope.$broadcast 'modalOpened', modal
      $timeout -> document.querySelector('md-dialog h1').focus()
      $scope = $rootScope.$new(true)
      $scope.$close = $mdDialog.cancel
      resolve.preventClose = resolve.preventClose or (-> false)
      modalType = opts.type || 'alert'
      currentModal =    $mdDialog[modalType](
        scope:          $scope
        templateUrl:    modal.templateUrl
        role:           'dialog'
        ariaLabel:      modal.ariaLabel || 'alert'
        controller:     modal.controller
        resolve:        resolve
        size:           (modal.size || '')
        backdrop:       'static'
        escapeToClose:  !resolve.preventClose()
      )
      $mdDialog.show(currentModal).finally -> currentModal = undefined
