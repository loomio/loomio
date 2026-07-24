import { marked } from 'marked';
import { clone } from 'lodash-es';
import parameterize from '@/shared/helpers/parameterize';

// marked (v4) does no protocol filtering, and the server-side HTML sanitizer
// never sees markdown link/image syntax — so `[x](javascript:...)` reaches the
// DOM verbatim. Drop any href/src whose scheme isn't safe.
const SAFE_SCHEME = /^(https?:|mailto:|tel:|ftp:|\/|#|\.|[^:]*$)/i;
const safeUrl = function(url) {
  // Strip control chars and whitespace (java\tscript:, leading newlines,
  // spaces) before testing the scheme so obfuscated payloads can't slip past.
  const trimmed = String(url == null ? '' : url).replace(/[\u0000-\u0020]+/g, '');
  return SAFE_SCHEME.test(trimmed) ? url : '#';
};

export var customRenderer = function(opts) {
  const _super   = new marked.Renderer(opts);
  const renderer = clone(_super);

  renderer.paragraph = text => _super.paragraph(text);
  renderer.listitem  = text => _super.listitem(text);
  renderer.tablecell = (text, flags) => _super.tablecell(text, flags);

  renderer.heading   = (text, level) => _super.heading(text, level, text, {slug: parameterize});

  renderer.link      = (href, title, text) => _super.link(safeUrl(href), title, text).replace('<a ', '<a rel="ugc noreferrer" target="_blank" ');
  renderer.image     = (href, title, text) => _super.image(safeUrl(href), title, text);

  return renderer;
};
export var options = {gfm: true, breaks: true, smartypants: false, tables: true};
