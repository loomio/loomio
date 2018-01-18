EventBus       = require 'shared/services/event_bus.coffee'

module.exports =
  setupVue: ->
    setupVueEventBus()

setupVueEventBus = ->
  EventBus.setEmitMethod (component, event, opts) ->
    component.$emit event, opts if typeof component.$emit is 'function'
  EventBus.setListenMethod (component, event, fn) ->
    component.$on event, fn if typeof component.$on is 'function'
