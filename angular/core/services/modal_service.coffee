angular.module('loomioApp').factory 'ModalService', ($mdDialog, $rootScope, $timeout, $translate, AppConfig) ->
  new class ModalService

    open: (modal, resolve) ->
      AppConfig.currentModal = buildModal(modal, resolve)
      $mdDialog.show(AppConfig.currentModal)
        .then    -> $rootScope.$broadcast 'modalOpened', modal
        .finally -> delete AppConfig.currentModal

    buildModal = (modal, resolve = {}) ->
      resolve = _.merge (preventClose: -> false), resolve
      $scope = $rootScope.$new(true)
      $scope.$close      = $mdDialog.cancel
      $scope.$on '$close', $mdDialog.cancel
      $scope.$on 'focus',  focusElement

      $mdDialog.alert
        role:           'dialog'
        backdrop:       'static'
        scope:          $scope
        templateUrl:    modal.templateUrl
        controller:     modal.controller
        size:           modal.size or ''
        resolve:        resolve
        escapeToClose:  !resolve.preventClose()
        ariaLabel:      $translate.instant("#{modal.templateUrl.split('/').pop().replace('.html', '')}.aria_label")
        onComplete:     focusElement

    focusElement = ->
      $timeout(->
        elementToFocus = document.querySelector('md-dialog [md-autofocus]') || document.querySelector('md-dialog h1')
        elementToFocus.focus()
      , 400)

    ariaLabel = (modal) ->
      $translate.instant "#{modal.templateUrl.split('/').pop().replace('.html', '')}.aria_label"
