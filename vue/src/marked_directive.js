import Vue from 'vue';
import {marked} from 'marked';
import {customRenderer, options} from '@/shared/helpers/marked';
marked.setOptions(Object.assign({renderer: customRenderer()}, options));
import { emojiReplaceText } from '@/shared/helpers/emojis';

const render = function(el, binding, vnode) {
  if (!binding.value) { return; }
  return el.innerHTML = emojiReplaceText(marked(binding.value));
};

export default Vue.directive('marked', {
  update: render,
  bind: render
});
