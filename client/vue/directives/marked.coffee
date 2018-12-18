markedHelper  = require('shared/helpers/marked')
{customRenderer, options, marked} = require 'shared/helpers/marked.coffee'

marked.setOptions Object.assign({renderer: customRenderer()}, options)

Vue.directive 'marked',
  update: (el, binding, vnode) ->
    el.innerHTML = marked(binding.value)
  bind: (el, binding, vnode) ->
    el.innerHTML = marked(binding.value)
