angular.module('loomioApp').factory 'ModalService', ($mdDialog, $rootScope, $timeout, $translate) ->
  currentModal = null
  new class ModalService
    open: (modal, resolve = {}, opts = {}) ->
      $rootScope.$broadcast 'modalOpened', modal
      $scope = $rootScope.$new(true)
      $scope.$close = $mdDialog.cancel
      $scope.focus = -> $timeout(->
        elementToFocus = document.querySelector('md-dialog [md-autofocus]') || document.querySelector('md-dialog h1')
        elementToFocus.focus()
      , 400)

      $scope.$on 'focus',  $scope.focus
      $scope.$on '$close', $scope.close

      resolve.preventClose = resolve.preventClose or (-> false)
      modalType = opts.type || 'alert'
      snakeCaseName =   modal.templateUrl.split('/').pop().replace('.html', '')
      currentModal =    $mdDialog[modalType](
        scope:          $scope
        onComplete:     $scope.focus
        templateUrl:    modal.templateUrl
        role:           'dialog'
        ariaLabel:      $translate.instant(snakeCaseName + ".aria_label")
        controller:     modal.controller
        resolve:        resolve
        size:           (modal.size || '')
        backdrop:       'static'
        escapeToClose:  !resolve.preventClose()
      )
      $mdDialog.show(currentModal).finally -> currentModal = undefined
