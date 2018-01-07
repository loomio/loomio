bowser = require 'bowser'

# a series of helpers related to the current browser window, such as the viewport size
# or printing. Hopefully we can pool all window-related functionality here, and
# then allow for an alternate implementation for when 'window' may not exist
module.exports =

  checkBrowser: ->
    if (bowser.safari and bowser.version < 9) or (bowser.ie and bowser.version < 10)
      hardReload('/417.html')

  exportGlobals: ->
    window._ = require 'lodash'

  initServiceWorker: ->
    if document.location.protocol.match(/https/) && navigator.serviceWorker?
      navigator.serviceWorker.register(document.location.origin + '/service-worker.js', scope: './')

  print:             -> window.print()
  is2x:              -> window.devicePixelRatio >= 2
  viewportSize:      -> viewportSize()
  hardReload: (path) -> hardReload(path)

hardReload = (path) ->
  if path
    window.location.href = path
  else
    window.location.reload()

viewportSize = ->
  if window.innerWidth < 480
    'small'
  else if window.innerWidth < 992
    'medium'
  else if window.innerWidth < 1280
    'large'
  else
    'extralarge'
