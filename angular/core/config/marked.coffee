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
    renderer.tablecell = (text, flags) -> _super.tablecell cook(text), flags

    renderer.heading   = (text, level) ->
      _super.heading(emojione.shortnameToImage(text), level, text)

    renderer.link      = (href, title, text) ->
      string = _super.link(href, title, text).replace('<a ', '<a rel="noopener noreferrer" target="_blank" ')
      string = string.replace('href="www', 'href="//www')
      string

    renderer

  _parse = marked.parse
  marked.parse = (src, opt, callback) ->
    src = src.replace(/<img[^>]+\>/ig, "")
    src = src.replace(/<script[^>]+\>/ig, "")
    return _parse(src, opt, callback)

  marked.Parser::parse = (src) ->
    @inline = new (marked.InlineLexer)(src.links, @options, @renderer)
    @inline.rules.url = /^((https?:\/\/|www)[^\s<]+[^<.,:;"')\]\s])/
    @inline.rules.text = /^[\s\S]+?(?=[\\<!\[_*`~]|https?:\/\/|www\.| {2,}\n|$)/
    @tokens = src.reverse()
    out = ''
    while @next()
      out += @tok()
    out

  markedProvider.setRenderer customRenderer(gfm: true, sanitize: true, breaks: true)
