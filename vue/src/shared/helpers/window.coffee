import bowser from 'bowser'
window.bowser = bowser

export hardReload = (path) ->
  if path
    window.location.href = path
  else
    window.location.reload()

export unsupportedBrowser = ->
  (bowser.safari and bowser.version < 9) or (bowser.ie and bowser.version < 11)

export deprecatedBrowser = ->
  bowser.msie and parseInt(bowser.version) <= 11

export print = -> window.print()
export is2x = -> window.devicePixelRatio >= 2
