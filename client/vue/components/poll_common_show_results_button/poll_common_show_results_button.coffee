EventBus = require 'shared/services/event_bus'

module.exports =
  data: ->
    clicked: false
  methods:
    press: ->
      EventBus.emit @, 'showResults'
      @clicked = true
  template:
    """
    <button v-if="!clicked" @click="press()" v-t="'poll_common_card.show_results'" class="md-accent show-results-button"></button>
    """
