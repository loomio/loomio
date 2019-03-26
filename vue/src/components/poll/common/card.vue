<style lang="scss">
</style>

<script lang="coffee">
Session  = require 'shared/services/session'
Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ listenForLoading } = require 'shared/helpers/listen'
{ myLastStanceFor }  = require 'shared/helpers/poll'

module.exports =
  props:
    poll: Object
  created: ->
    Records.polls.findOrFetchById(@poll.key)
    EventBus.$on 'showResults', => @buttonPressed = true
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    # listenForLoading @
  data: ->
    buttonPressed: false
  methods:
    showResults: ->
      @buttonPressed || myLastStanceFor(@poll)? || @poll.isClosed()
</script>

<template lang="pug">
v-card
  // <div v-if="isDisabled" class="lmo-disabled-form"></div>
  loading(v-if='!poll.complete')
  .lmo-blank(v-if='poll.complete')
    poll-common-card-header.px-4(:poll='poll')
    v-card-text
      poll-common-set-outcome-panel(:poll='poll')
      h1.poll-common-card__title(v-if='!poll.translation') {{poll.title}}
      h3.lmo-h1.poll-common-card__title(v-if='poll.translation')
        translation(:model='poll', :field='title')
      poll-common-outcome-panel(:poll='poll', v-if='poll.outcome()')
      poll-common-details-panel(:poll='poll')
      .poll-common-card__results-shown(v-if='showResults()')
        poll-common-directive(:poll='poll', name='chart-panel')
        poll-common-add-option-button(:poll='poll')
        poll-common-percent-voted(:poll='poll')
    poll-common-action-panel(:poll='poll')
    .poll-common-card__results-shown(v-if='showResults()')
      poll-common-votes-panel(:poll='poll')
</template>
