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
export isValidBrowser = browser.satisfies({

  # // per platform (mobile, desktop or tablet)
  mobile: {
    safari: '>=12',
    'android browser': '>=76'
    chrome: '>0'
    firefox: '>0'
  },

  # // or in general
  chrome: ">=0",
  firefox: ">=0",
  opera: ">0"
  'internet explorer': ">11"
  msedge: ">=16"
  safari: ">=12"
})
