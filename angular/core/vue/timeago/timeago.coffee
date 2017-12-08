angular.module('loomioApp').directive 'vueTimeago', (createVueComponent) ->
  createVueComponent Vue.component 'vue-timeago',
    props:
      timestamp: Object
    created:       -> this.tick = setInterval(this.$forceUpdate(), 1000*60) # update once per minute
    beforeDestroy: -> clearInterval(this.tick)
    render: (h) ->
      h 'span',
        class: 'vue-timeago'
        title: this.timestamp.format('dddd MMMM Do [at] h:mm a')
      , this.timestamp.fromNow(true)
