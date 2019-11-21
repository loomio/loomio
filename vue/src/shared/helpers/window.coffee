import Bowser from 'bowser'
window.bowser = Bowser

export hardReload = (path) ->
  if path
    window.location.href = path
  else
    window.location.reload()

export print = -> window.print()
export is2x = -> window.devicePixelRatio >= 2

browser = Bowser.getParser(window.navigator.userAgent)
browserName = browser.parsedResult.browser.name
browserVersion = parseInt(browser.parsedResult.browser.version)

export isIncompatibleBrowser =
  (browserName == 'Internet Explorer') ||
  (browserName == 'Microsoft Edge' && browserVersion < 17) ||
  (browserName == 'Safari' && browserVersion < 12) ||
  (browserName == 'Firefox' && browserVersion < 50)
