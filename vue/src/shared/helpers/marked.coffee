# import emojione from 'emojione'
import marked from 'marked'
import { clone, kebabCase } from 'lodash'
import { colonsToUnicode } from '@/shared/helpers/emojis'

# _parse = marked.parse
# marked.parse = (src, opt, callback) ->
#   src = src.replace(/<img[^>]+\>/ig, "")
#   src = src.replace(/<script[^>]+\>/ig, "")
#   return _parse(src, opt, callback)
#
# export marked = marked

export customRenderer = (opts) ->
  _super   = new marked.Renderer(opts)
  renderer = clone(_super)
  cook = (text) ->
    text = colonsToUnicode(text)
    text = text.replace(/\[\[@([a-zA-Z0-9]+)\]\]/g, "<a class='lmo-user-mention' href='/u/$1'>@$1</a>")
    text

  renderer.paragraph = (text) -> _super.paragraph cook(text)
  renderer.listitem  = (text) -> _super.listitem  cook(text)
  renderer.tablecell = (text, flags) -> _super.tablecell cook(text), flags

  renderer.heading   = (text, level) ->
    _super.heading(colonsToUnicode(text), level, text, {slug: kebabCase})

  renderer.link      = (href, title, text) ->
    _super.link(href, title, text).replace('<a ', '<a rel="noopener noreferrer" target="_blank" ')

  renderer
export options = {gfm: true, breaks: true, smartypants: false, tables: true}
