AppConfig    = require 'shared/services/app_config.coffee'
ModalService = require 'shared/services/modal_service.coffee'
FlashService = require 'shared/services/flash_service.coffee'

{ listenForLoading } = require 'angular/helpers/loading.coffee'

module.exports =
  setupAngularModal: ($rootScope, $injector, $translate, $mdDialog) ->
    ModalService.setOpenMethod (name, resolve = {}) ->
      modal                  = $injector.get(name)
      resolve.preventClose   = resolve.preventClose or (-> false)
      AppConfig.currentModal = $mdDialog.alert
        role:           'dialog'
        backdrop:       'static'
        scope:          buildScope($rootScope, $mdDialog)
        templateUrl:    modal.templateUrl
        controller:     modal.controller
        size:           modal.size or ''
        resolve:        resolve
        escapeToClose:  !resolve.preventClose()
        ariaLabel:      $translate.instant(ariaFor(modal))
        onComplete:     focusElement

      $mdDialog.show(AppConfig.currentModal)
        .then    -> $rootScope.$broadcast 'modalOpened', modal
        .finally -> delete AppConfig.currentModal

  setupAngularFlash: ($rootScope) ->
    FlashService.setBroadcastMethod (flashOptions) ->
      $rootScope.$broadcast 'flashMessage', flashOptions

buildScope = ($rootScope, $mdDialog) ->
  $scope = $rootScope.$new(true)
  $scope.$close = $mdDialog.cancel
  $scope.$on '$close', $scope.$close
  $scope.$on 'focus', focusElement
  listenForLoading $scope
  $scope

ariaFor = (modal) ->
  "#{modal.templateUrl.split('/').pop().replace('.html', '')}.aria_label"

focusElement = ->
  setTimeout ->
    elementToFocus = document.querySelector('md-dialog [md-autofocus]') || document.querySelector('md-dialog h1')
    elementToFocus.focus()
    angular.element(window).triggerHandler('checkInView')
  , 400
