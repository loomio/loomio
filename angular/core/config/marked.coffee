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
      if marked.InlineLexer.rules.gfm.url.test(href) and !/^http/.test(href)
        href = 'http://' + href
      _super.link(href, title, text).replace('<a ', '<a rel="noopener noreferrer" target="_blank" ')

    renderer

  _parse = marked.parse
  marked.parse = (src, opt, callback) ->
    marked.InlineLexer.rules.gfm.url = /^((https?:\/\/)?([a-z0-9+!*(),;?&=.-]+(:[a-z0-9+!*(),;?&=.-]+)?@)?([a-z0-9\-\.]*)\.(([a-z]{2,4})|([0-9]{1,3}\.([0-9]{1,3})\.([0-9]{1,3})))(:[0-9]{2,5})?(\/([a-z0-9+%-]\.?)+)*\/?(\?[a-z+&$_.-][a-z0-9;:@&%=+/.-]*)?(#[a-z_.-][a-z0-9+$%_.-]*)?)/i
    src = src.replace(/<img[^>]+\>/ig, "")
    src = src.replace(/<script[^>]+\>/ig, "")
    return _parse(src, opt, callback)

  markedProvider.setRenderer customRenderer(gfm: true, sanitize: true, breaks: true)
