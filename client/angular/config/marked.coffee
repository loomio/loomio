emojione = require 'emojione'
marked   = require 'marked'

angular.module('loomioApp').config ['markedProvider', (markedProvider) ->
  customRenderer = (opts) ->
    _super   = new marked.Renderer(opts)
    renderer = _.clone(_super)
    cook = (text) ->
      text = emojione.shortnameToImage(text)
      text = text.replace(/\[\[@([a-zA-Z0-9]+)\]\]/g, "<a class='lmo-user-mention' href='/u/$1'>@$1</a>")
      text

    renderer.paragraph = (text) -> _super.paragraph cook(text)
    renderer.listitem  = (text) -> _super.listitem  cook(text)
    renderer.tablecell = (text, flags) -> _super.tablecell cook(text), flags

    emojione.unicodeAlt = false
    emojione.imagePathPNG = "/img/emojis/"
    emojione.ascii = true

    renderer.heading   = (text, level) ->
      _super.heading(emojione.shortnameToImage(text), level, text)

    renderer.link      = (href, title, text) ->
      _super.link(href, title, text).replace('<a ', '<a rel="noopener noreferrer" target="_blank" ')

    renderer

  _parse = marked.parse
  marked.parse = (src, opt, callback) ->
    src = src.replace(/<img[^>]+\>/ig, "")
    src = src.replace(/<script[^>]+\>/ig, "")
    return _parse(src, opt, callback)

  options = {gfm: true, sanitize: true, breaks: true, smartypants: false, tables: true}
  markedProvider.setRenderer customRenderer()
  markedProvider.setOptions options
]
