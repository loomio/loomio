bowser = require 'bowser'

{ hardReload } = require 'shared/helpers/window.coffee'

if (bowser.safari and bowser.version < 9) or (bowser.ie and bowser.version < 10)
  hardReload('/417.html')
