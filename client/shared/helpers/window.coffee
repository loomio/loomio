IntercomService = require 'shared/services/intercom_service.coffee'
ModalService    = require 'shared/services/modal_service.coffee'
ScrollService   = require 'shared/services/scroll_service.coffee'

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
      ScrollService.scrollTo(
        document.querySelector(target),
        document.querySelector(options.container or '.lmo-main-content'),
        options
      )
