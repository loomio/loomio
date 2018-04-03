bowser = require 'bowser'
window.bowser = bowser

# a series of helpers related to the current browser window, such as the viewport size
# or printing. Hopefully we can pool all window-related functionality here, and
# then allow for an alternate implementation for when 'window' may not exist
module.exports =

  unsupportedBrowser: ->
    (bowser.safari and bowser.version < 9) or (bowser.ie and bowser.version < 11)

  deprecatedBrowser: ->
    bowser.msie and parseInt(bowser.version) <= 11

  exportGlobals: ->
    window.moment = require 'moment'
    window._      = require 'lodash'
    _.extend window._, require 'shared/helpers/lodash_ext.coffee'

  initServiceWorker: ->
    version = document.querySelector('meta[name=version]').content
    if (version == 'development' || document.location.protocol.match(/https/)) && navigator.serviceWorker?
      navigator.serviceWorker.register("#{document.location.origin}/service-worker.js?#{version}", scope: "./")

  print:             -> window.print()
  is2x:              -> window.devicePixelRatio >= 2
  triggerResize:     -> setTimeout -> window.dispatchEvent(new window.Event('resize')) if window.Event
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
