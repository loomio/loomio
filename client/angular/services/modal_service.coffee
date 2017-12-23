AppConfig      = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'ModalService', ($mdDialog, $injector, $rootScope, $timeout, $translate, LoadingService) ->
  new class ModalService

    open: (modal, resolve) ->
      AppConfig.currentModal = buildModal(modal, resolve)
      $mdDialog.show(AppConfig.currentModal)
        .then    -> $rootScope.$broadcast 'modalOpened', modal
        .finally -> delete AppConfig.currentModal

    buildModal = (modal, resolve = {}) ->
      modal = $injector.get(modal) if typeof modal == 'string'
      resolve = _.merge (preventClose: -> false), resolve
      $scope = $rootScope.$new(true)
      $scope.$close      = $mdDialog.cancel
      $scope.$on '$close', $mdDialog.cancel
      $scope.$on 'focus',  focusElement
      LoadingService.listenForLoading $scope

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
        angular.element(window).triggerHandler('checkInView')
      , 400)

    ariaLabel = (modal) ->
      $translate.instant "#{modal.templateUrl.split('/').pop().replace('.html', '')}.aria_label"
