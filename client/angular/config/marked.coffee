{customRenderer, options, marked} = require 'shared/helpers/marked.coffee'

angular.module('loomioApp').config ['markedProvider', (markedProvider) ->
    markedProvider.setRenderer customRenderer()
    markedProvider.setOptions options
]
