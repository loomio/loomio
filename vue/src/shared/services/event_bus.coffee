import Vue from 'vue'
EventBus = new Vue()
wrapper =
  $on: (...args) ->
    # console.log "eventbus.$on", args
    EventBus.$on(...args)

  $emit: (...args) ->
    # console.log "eventbus.$emit", args
    EventBus.$emit(...args)

window.Loomio.eventBus = wrapper

export default wrapper
