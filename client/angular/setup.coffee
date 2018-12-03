Routes         = require 'angular/routes'
AppConfig      = require 'shared/services/app_config'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
FlashService   = require 'shared/services/flash_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
ScrollService  = require 'shared/services/scroll_service'
I18n           = require 'shared/services/i18n'

{ listenForLoading } = require 'shared/helpers/listen'
{ registerHotkeys }  = require 'shared/helpers/keyboard'

# a series of helpers to apply angular-specific implementations to the vanilla Loomio app,
# such as how to open modals or display a flash message
module.exports =
  setupAngular: ($rootScope, $injector) ->
    setupAngularScroll()
    setupAngularEventBus()
    setupMatomo($rootScope, $injector.get('$analytics'))
    setupAngularPaste($rootScope)
    setupAngularHotkeys($rootScope)
    setupAngularFlash($rootScope)
    setupAngularRoutes($injector.get('$router'))
    setupAngularNavigate($injector.get('$location'))
    setupAngularTranslate($rootScope, $injector.get('$translate'))
    setupAngularDigest($rootScope, $injector)
    setupAngularModal($rootScope, $injector)

setupMatomo = ($rootScope, $analytics) ->
  EventBus.listen $rootScope, 'currentComponent', =>
    $analytics.pageTrack(window.location.pathname);

setupAngularScroll = ->
  ScrollService.setScrollMethod (elem, container, options = {}) ->
    return unless elem and container
    options.offset = document.documentElement.clientHeight - (options.offset or 100) if options.bottom
    angular.element(container).scrollToElement(elem, options.offset or 50, options.speed or 100).then ->
      angular.element(window).triggerHandler('checkInView')
      elem.focus()

setupAngularEventBus = ->
  EventBus.setEmitMethod (scope, event, opts) ->
    scope.$emit event, opts         if typeof scope.$emit is 'function'
  EventBus.setBroadcastMethod (scope, event, opts...) ->
    scope.$broadcast event, opts... if typeof scope.$broadcast is 'function'
  EventBus.setListenMethod (scope, event, fn) ->
    scope["#{event}Listener"] = scope.$on event, fn if typeof scope.$on is 'function'
  EventBus.setDeafenMethod (scope, event) ->
    scope["#{event}Listener"]()     if typeof scope["#{event}Listener"] is 'function'
  EventBus.setWatchMethod (scope, fields, fn, watchObj = false) ->
    scope.$watch fields, fn, watchObj

setupAngularPaste = ($rootScope) ->
  window.addEventListener 'paste', (event) ->
    data = event.clipboardData
    return unless item = _.head _.filter(data.items, (item) -> item.getAsFile())
    event.preventDefault()
    file = new File [item.getAsFile()], data.getData('text/plain') || Date.now(),
      lastModified: Date.now()
      type:         item.type
    EventBus.broadcast $rootScope, 'filesPasted', [file]

setupAngularHotkeys = ($rootScope) ->
  registerHotkeys $rootScope,
    pressedI: ->
      return unless currentModel = AppConfig.currentPoll || AppConfig.currentDiscussion || AppConfig.currentGroup
      ModalService.open 'AnnouncementModal', announcement: -> Records.announcements.buildFromModel(currentModel)
    pressedG: -> ModalService.open 'GroupModal',           group:        -> Records.groups.build()
    pressedT: -> ModalService.open 'DiscussionStartModal', discussion:   -> Records.discussions.build(groupId: (AppConfig.currentGroup or {}).id)
    pressedP: -> ModalService.open 'PollCommonStartModal', poll:         -> Records.polls.build()
    pressedS: -> EventBus.broadcast $rootScope, 'toggleSidebar'

setupAngularFlash = ($rootScope) ->
  FlashService.setBroadcastMethod (flashOptions) ->
    EventBus.broadcast $rootScope, 'flashMessage', flashOptions

setupAngularRoutes = ($router) ->
  $router.config(Routes.concat(AppConfig.plugins.routes))

setupAngularNavigate = ($location) ->
  LmoUrlService.setGoToMethod   (path, newTab)    ->
    if newTab
      window.open(path, '_blank')
    else
      $location.path(path)
  LmoUrlService.setParamsMethod (args...) -> $location.search(args...)

setupAngularTranslate = ($rootScope, $translate) ->
  $translate.onReady -> $rootScope.translationsLoaded = true
  I18n.setUseLocaleMethod (locale)         -> $translate.use(locale)
  I18n.setTranslateMethod (key, opts = {}) -> $translate.instant(key, opts)

setupAngularDigest = ($rootScope, $injector) ->
  $browser = $injector.get('$browser')
  $timeout = $injector.get('$timeout')
  Records.afterImport = -> $timeout -> $rootScope.$apply()
  Records.setRemoteCallbacks
    onPrepare: -> $browser.$$incOutstandingRequestCount()
    onCleanup: -> $browser.$$completeOutstandingRequest -> $timeout -> $rootScope.$apply()

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
