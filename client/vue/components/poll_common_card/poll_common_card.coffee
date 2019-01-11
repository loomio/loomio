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
    EventBus.listen @, 'showResults', =>
      @buttonPressed = true
    EventBus.listen @, 'stanceSaved', =>
      EventBus.broadcast @, 'refreshStance'
    listenForLoading @
  data: ->
    buttonPressed: false
  methods:
    showResults: ->
      @buttonPressed || myLastStanceFor(@poll)? || @poll.isClosed()
  template:
    """
    <section class="poll-common-card lmo-card-padding lmo-flex__grow lmo-relative">
      <!-- <div v-if="isDisabled" class="lmo-disabled-form"></div> -->
      <loading v-if="!poll.complete"></loading>
      <div v-if="poll.complete" class="lmo-blank">
        <poll-common-card-header :poll="poll"></poll-common-card-header>
        <poll-common-set-outcome-panel :poll="poll"></poll-common-set-outcome-panel>
        <h1 v-if="!poll.translation" class="poll-common-card__title">{{poll.title}}</h1>
        <h3 v-if="poll.translation" class="lmo-h1 poll-common-card__title">
          <translation :model="poll" :field="title"></translation>
        </h3>
        <poll-common-outcome-panel :poll="poll" v-if="poll.outcome()"></poll-common-outcome-panel>
        <poll-common-details-panel :poll="poll"></poll-common-details-panel>
        <div v-if="showResults()" class="poll-common-card__results-shown">
          <poll-common-directive :poll="poll" name="chart_panel"></poll-common-directive>
          <poll-common-add-option-button :poll="poll"></poll-common-add-option-button>
          <poll-common-percent-voted :poll="poll"></poll-common-percent-voted>
        </div>
        <poll-common-action-panel :poll="poll"></poll-common-action-panel>
        <div v-if="showResults()" class="poll-common-card__results-shown">
          <poll-common-votes-panel :poll="poll"></poll-common-votes-panel>
        </div>
      </div>
    </section>
    """
