import Vue from 'vue'
import {marked} from 'marked'
import {customRenderer, options} from '@/shared/helpers/marked'
marked.setOptions Object.assign({renderer: customRenderer()}, options)
import { emojiReplaceText } from '@/shared/helpers/emojis'

render = (el, binding, vnode) ->
  return unless binding.value
  el.innerHTML = emojiReplaceText(marked(binding.value))

export default Vue.directive 'marked',
  update: render
  bind: render
