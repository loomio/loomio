import Vue from 'vue'
import marked from 'marked'
import {customRenderer, options} from '@/shared/helpers/marked.coffee'
marked.setOptions Object.assign({renderer: customRenderer()}, options)
import { emojiReplaceText } from '@/shared/helpers/emojis.coffee'

render = (el, binding, vnode) ->
  return unless binding.value
  el.innerHTML = emojiReplaceText(marked(binding.value))

export default Vue.directive 'marked',
  update: render
  bind: render
