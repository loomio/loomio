import { marked } from 'marked';
import { clone, kebabCase } from 'lodash-es';
import { colonsToUnicode } from '@/shared/helpers/emojis';
import parameterize from '@/shared/helpers/parameterize';

// _parse = marked.parse
// marked.parse = (src, opt, callback) ->
//   src = src.replace(/<img[^>]+\>/ig, "")
//   src = src.replace(/<script[^>]+\>/ig, "")
//   return _parse(src, opt, callback)
//
// export marked = marked


export var customRenderer = function(opts) {
  const _super   = new marked.Renderer(opts);
  const renderer = clone(_super);

  renderer.paragraph = text => _super.paragraph(colonsToUnicode(text));
  renderer.listitem  = text => _super.listitem(colonsToUnicode(text));
  renderer.tablecell = (text, flags) => _super.tablecell(colonsToUnicode(text), flags);

  renderer.heading   = (text, level) => _super.heading(colonsToUnicode(text), level, text, {slug: parameterize});

  renderer.link      = (href, title, text) => _super.link(href, title, text).replace('<a ', '<a rel="ugc noreferrer" target="_blank" ');

  return renderer;
};
export var options = {gfm: true, breaks: true, smartypants: false, tables: true};
