angular.module('loomioApp').config (markedProvider) ->
  customRenderer = (opts) ->
    _super   = new marked.Renderer(opts)
    renderer = _.clone(_super)
    cook = (text) ->
      text = emojione.shortnameToImage(text)
      text = text.replace(/\[\[@([a-zA-Z0-9]+)\]\]/g, "<a class='lmo-user-mention' href='/u/$1'>@$1</a>")
      text

    renderer.paragraph = (text) -> _super.paragraph cook(text)
    renderer.listitem  = (text) -> _super.listitem  cook(text)
    renderer.tablecell = (text) -> _super.tablecell cook(text)

    renderer.heading   = (text, level) ->
      _super.heading(emojione.shortnameToImage(text), level, text)

    renderer.link      = (href, title, text) ->
      _super.link(href, title, text).replace('<a ', '<a rel="noopener noreferrer" target="_blank" ')

    renderer

  markedProvider.setRenderer customRenderer(gfm: true, sanitize: true, breaks: true)
