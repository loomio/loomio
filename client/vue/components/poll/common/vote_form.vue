<style lang="scss">
@import 'variables';
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

    @submit = submitStance @, @stance,
      prepareFn: ->
        @stance.id = null
        @stance.stanceChoicesAttributes = [
          poll_option_id: @selectedOptionId
        ]
  methods:
    orderedPollOptions: ->
      _.sortBy @stance.poll().pollOptions(), 'priority'

    isSelected: (option) ->
      @selectedOptionId == option.id

    mdColors: (option) ->
      buttonStyle(@selectedOptionId == option.id)

    select: (option) ->
      @selectedOptionId = option.id
      @$nextTick => EventBus.broadcast @, 'focusTextarea'
</script>

<template lang="pug">
.poll-common-vote-form
  h3.lmo-card-subheading(v-t="'poll_common.your_response'", v-if='stance.isNew()')
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous')
  .poll-common-vote-form__options.lmo-flex--row.lmo-flex__horizontal-center
    button.lmo-flex--column.poll-common-vote-form__button(md-colors='mdColors(option)', v-for='option in orderedPollOptions()', :key='option.id', @click='select(option)')
      img.poll-common-form__icon(:src="'/img/' + option.name + '.svg'")
      span.poll-common-vote-form__chosen-option--name(v-t="'poll_' + stance.poll().pollType + '_options.' + option.name", aria-label='option.name')
      // <md-tooltip md-delay="750" class="poll-common-vote-form__tooltip"><span translate="poll_{{stance.poll().pollType}}_options.{{option.name}}_meaning"></span></md-tooltip>
  poll-common-stance-reason.animated(:stance='stance', v-show='selectedOptionId', v-if='stance')
  .lmo-md-actions
    div(v-if='!stance.isNew()')
    poll-common-show-results-button(v-if='stance.isNew()')
    button.md-primary.md-raised.poll-common-vote-form__submit(@click='submit()', v-t="'poll_common.vote'", :disabled='!selectedOptionId')

</template>
