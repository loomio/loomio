angular.module('loomioApp').config (markedProvider, renderProvider) ->
  markedProvider.setOptions
    gfm: true
    sanitize: true
    breaks: true
  markedProvider.setRenderer(renderProvider.$get(0).createRenderer())
