import {marked} from 'marked';
import {customRenderer, options} from '@/shared/helpers/marked';

export var convertToHtml = function(model, field) {
  marked.setOptions(Object.assign({renderer: customRenderer()}, options));
  model[`${field}Format`] = "html";
  return model[field] = marked(model[field] || '');
};

export var convertToMd = (model, field) => import('turndown').then(function(Turndown) {
  // import('turndown-plugin-gfm').then (TurndownPluginGfm) ->
  //   gfm = TurndownPluginGfm.gfm

  const converter = Turndown.default({
    headingStyle: 'atx',
    hr: '---',
    codeBlockStyle: 'fenced'
  });

  converter.addRule('mentions', {
    filter: 'span',
    replacement(content, node, options) {
      return '@' + node.getAttribute('data-mention-id');
    }
  }
  );

  model[`${field}Format`] = "md";
  return model[field] = converter.turndown(model[field] || '');
});
