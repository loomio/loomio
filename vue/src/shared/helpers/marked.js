import { marked } from 'marked';
import { clone } from 'lodash-es';
import parameterize from '@/shared/helpers/parameterize';

export var customRenderer = function(opts) {
  const _super   = new marked.Renderer(opts);
  const renderer = clone(_super);

  renderer.paragraph = text => _super.paragraph(text);
  renderer.listitem  = text => _super.listitem(text);
  renderer.tablecell = (text, flags) => _super.tablecell(text, flags);

  renderer.heading   = (text, level) => _super.heading(text, level, text, {slug: parameterize});

  renderer.link      = (href, title, text) => _super.link(href, title, text).replace('<a ', '<a rel="ugc noreferrer" target="_blank" ');

  return renderer;
};
export var options = {gfm: true, breaks: true, smartypants: false, tables: true};