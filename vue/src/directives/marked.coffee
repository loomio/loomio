markedHelper  = require('shared/helpers/marked')
{customRenderer, options, marked} = require 'shared/helpers/marked.coffee'
import Vue from 'vue'

marked.setOptions Object.assign({renderer: customRenderer()}, options)

render = (el, binding, vnode) ->
  return unless binding.value
  el.innerHTML = marked(binding.value)

Vue.directive 'marked',
  update: render
  bind: render
