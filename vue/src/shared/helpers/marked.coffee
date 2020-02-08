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

  renderer.paragraph = (text) -> _super.paragraph colonsToUnicode(text)
  renderer.listitem  = (text) -> _super.listitem  colonsToUnicode(text)
  renderer.tablecell = (text, flags) -> _super.tablecell colonsToUnicode(text), flags

  renderer.heading   = (text, level) ->
    _super.heading(colonsToUnicode(text), level, text, {slug: kebabCase})

  renderer.link      = (href, title, text) ->
    _super.link(href, title, text).replace('<a ', '<a rel="ugc noreferrer" target="_blank" ')

  renderer
export options = {gfm: true, breaks: true, smartypants: false, tables: true}
