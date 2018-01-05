AppConfig     = require 'shared/services/app_config.coffee'
EventBus      = require 'shared/services/event_bus.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
FlashService  = require 'shared/services/flash_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'
ScrollService = require 'shared/services/scroll_service.coffee'
I18n          = require 'shared/services/i18n.coffee'

{ listenForLoading } = require 'angular/helpers/listen.coffee'

# a series of helpers to apply angular-specific implementations to the vanilla Loomio app,
# such as how to open modals or display a flash message
module.exports =
  setupAngular: ($rootScope, $injector) ->
    setupAngularScroll()
    setupAngularBroadcast()
    setupAngularFlash($rootScope)
    setupAngularNavigate($injector.get('$location'))
    setupAngularTranslate($rootScope, $injector.get('$translate'))
    setupAngularModal($rootScope, $injector)

setupAngularScroll = ->
  ScrollService.setScrollMethod (elem, container, options = {}) ->
    return unless elem and container
    options.offset = document.documentElement.clientHeight - (options.offset or 100) if options.bottom
    angular.element(container).scrollToElement(elem, options.offset or 50, options.speed or 100).then ->
      angular.element(window).triggerHandler('checkInView')
      elem.focus()

setupAngularBroadcast = ->
  EventBus.setEmitMethod (scope, event, opts) ->
    scope.$emit event, opts         if typeof scope.$emit is 'function'
  EventBus.setBroadcastMethod (scope, event, opts...) ->
    scope.$broadcast event, opts... if typeof scope.$broadcast is 'function'
  EventBus.setListenMethod (scope, event, fn) ->
    scope.$on event, fn             if typeof scope.$on is 'function'

setupAngularFlash = ($rootScope) ->
  FlashService.setBroadcastMethod (flashOptions) ->
    EventBus.broadcast $rootScope, 'flashMessage', flashOptions

setupAngularNavigate = ($location) ->
  LmoUrlService.setGoToMethod   (path)    -> $location.path(path)
  LmoUrlService.setParamsMethod (args...) -> $location.search(args...)

setupAngularTranslate = ($rootScope, $translate) ->
  $translate.onReady -> $rootScope.translationsLoaded = true
  I18n.setUseLocaleMethod (locale)         -> $translate.use(locale)
  I18n.setTranslateMethod (key, opts = {}) -> $translate.instant(key, opts)

setupAngularModal = ($rootScope, $injector, $mdDialog) ->
  $mdDialog = $injector.get('$mdDialog')
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
      ariaLabel:      I18n.t(ariaFor(modal))
      onComplete:     focusElement

    $mdDialog.show(AppConfig.currentModal)
      .then    -> EventBus.broadcast $rootScope, 'modalOpened', modal
      .finally -> delete AppConfig.currentModal

buildScope = ($rootScope, $mdDialog) ->
  $scope = $rootScope.$new(true)
  $scope.$close = $mdDialog.cancel
  EventBus.listen $scope, '$close', $scope.$close
  EventBus.listen $scope, 'focus', focusElement
  listenForLoading $scope
  $scope

ariaFor = (modal) ->
  "#{modal.templateUrl.split('/').pop().replace('.html', '')}.aria_label"

focusElement = ->
  setTimeout ->
    elementToFocus = document.querySelector('md-dialog [md-autofocus]') || document.querySelector('md-dialog h1')
    elementToFocus.focus() if elementToFocus
    angular.element(window).triggerHandler('checkInView')
  , 400
