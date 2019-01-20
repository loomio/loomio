<style lang="scss">
.poll-common-vote-form__button {
  border: 2px solid $background-color;
  min-width: auto;
  max-width: calc(25% - 8px) !important;
  overflow: visible;
  white-space: normal;
  img {
    width: 80px;
    padding: 8px;
  }
  @media (max-width: $tiny-max-px) {
    margin: 0;
    min-width: 64px !important;
    img { width: 64px; }
  }
  &--block { max-width: 100% !important; }
}

</style>

<script lang="coffee">
EventBus = require 'shared/services/event_bus'

{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitStance }  = require 'shared/helpers/form'
{ buttonStyle }   = require 'shared/helpers/style'

module.exports =
  props:
    stance: Object
  data: ->
    selectedOptionId: @stance.pollOptionId()
  mounted: ->
    submitOnEnter @, element: @$el
  methods:
    orderedPollOptions: ->
      _.sortBy @stance.poll().pollOptions(), 'priority'

    # submit: submitStance @, @stance,
    #   prepareFn: ->
    #     @stance.id = null
    #     @stance.stanceChoicesAttributes = [
    #       poll_option_id: @selectedOptionId
    #     ]

    isSelected: (option) ->
      @selectedOptionId == option.id

    mdColors: (option) ->
      buttonStyle(@selectedOptionId == option.id)

    select: (option) ->
      @selectedOptionId = option.id
      @$nextTick => EventBus.broadcast @, 'focusTextarea'
</script>

<template>
    <div class="poll-common-vote-form lmo-drop-animation">
      <h3 v-t="'poll_common.your_response'" v-if="stance.isNew()" class="lmo-card-subheading"></h3>
      <poll-common-anonymous-helptext v-if="stance.poll().anonymous"></poll-common-anonymous-helptext>
      <div class="poll-common-vote-form__options lmo-flex--row lmo-flex__horizontal-center">
        <button
          md-colors="mdColors(option)"
          v-for="option in orderedPollOptions()"
          :key="option.id"
          @click="select(option)"
          class="lmo-flex--column poll-common-vote-form__button"
        >
          <img :src="'/img/' + option.name + '.svg'" class="poll-common-form__icon">
          <span
            v-t="'poll_' + stance.poll().pollType + '_options.' + option.name"
            aria-label="option.name"
            class="poll-common-vote-form__chosen-option--name"
          ></span>
          <!-- <md-tooltip md-delay="750" class="poll-common-vote-form__tooltip"><span translate="poll_{{stance.poll().pollType}}_options.{{option.name}}_meaning"></span></md-tooltip> -->
        </button>
      </div>
      <poll-common-stance-reason :stance="stance" v-show="selectedOptionId" v-if="stance" class="animated"></poll-common-stance-reason>
      <div class="lmo-md-actions">
        <div v-if="!stance.isNew()"></div>
        <poll-common-show-results-button v-if="stance.isNew()"></poll-common-show-results-button>
        <button @click="submit()" v-t="'poll_common.vote'" :disabled="!selectedOptionId" class="md-primary md-raised poll-common-vote-form__submit"></button>
      </div>
    </div>
</template>
