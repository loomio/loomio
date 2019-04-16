import Vue from 'vue'
EventBus = new Vue()
export default
  $on: (...args) ->
    console.log "eventbus.$on", args
    EventBus.$on(...args)

  $emit: (...args) ->
    console.log "eventbus.$emit", args
    EventBus.$emit(...args)
