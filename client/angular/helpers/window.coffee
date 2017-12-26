IntercomService = require 'shared/services/intercom_service.coffee'
ModalService    = require 'shared/services/modal_service.coffee'

# a series of helpers related to the current browser window, such as the viewport size
# or printing. Hopefully we can pool all window-related functionality here, and
# then allow for an alternate implementation for when 'window' may not exist
module.exports =
  viewportSize: ->
    if window.innerWidth < 480
      'small'
    else if window.innerWidth < 992
      'medium'
    else if window.innerWidth < 1280
      'large'
    else
      'extralarge'

  hardReload: (path) ->
    if path
      window.location.href = path
    else
      window.location.reload()

  print: ->
    window.print()

  contactUs: ->
    if IntercomService.available()
      IntercomService.open()
    else
      ModalService.open('ContactModal')

  is2x: ->
    window.devicePixelRatio >= 2

  scrollTo: (target, options = {}) ->
    setTimeout ->
      elem      = document.querySelector(target)
      container = document.querySelector(options.container or '.lmo-main-content')
      if options.bottom
          options.offset = document.documentElement.clientHeight - (options.offset or 100)
      if elem && container
        angular.element(container).scrollToElement(elem, options.offset or 50, options.speed or 100).then ->
          angular.element(window).triggerHandler('checkInView')
        elem.focus()

  trackEvents: ($scope) ->
    return unless ahoy?

    ahoy.trackClicks()
    ahoy.trackSubmits()
    ahoy.trackChanges()

    # track page views
    $scope.$on 'currentComponent', =>
      ahoy.track '$view',
        page:  window.location.pathname
        url:   window.location.href
        title: document.title

    # track modal views
    $scope.$on 'modalOpened', (_, modal) =>
      ahoy.track 'modalOpened',
        name: modal.templateUrl.match(/(\w+)\.html$/)[1]
