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
    # submitOnEnter @, element: @$el
    @submit = submitStance @, @stance,
      prepareFn: =>
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
      @$nextTick => EventBus.$emit 'focusTextarea'
</script>

<template lang="pug">
.poll-common-vote-form
  v-subheader(v-t="'poll_common.your_response'", v-if='stance.isNew()')
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous')
  v-layout
    v-btn.poll-common-vote-form__button(fab large flat md-colors='mdColors(option)', v-for='option in orderedPollOptions()', :key='option.id', @click='select(option)')
      v-avatar(size="64px")
        img(:src="'/img/' + option.name + '.svg'")
      //- span.poll-common-vote-form__chosen-option--name(v-t="'poll_' + stance.poll().pollType + '_options.' + option.name", aria-label='option.name')
      // <md-tooltip md-delay="750" class="poll-common-vote-form__tooltip"><span translate="poll_{{stance.poll().pollType}}_options.{{option.name}}_meaning"></span></md-tooltip>
  poll-common-stance-reason.animated(:stance='stance', v-show='selectedOptionId', v-if='stance')
  v-card-actions
    div(v-if='!stance.isNew()')
    poll-common-show-results-button(v-if='stance.isNew()')
    v-btn.poll-common-vote-form__submit(color="primary", @click='submit()', v-t="'poll_common.vote'", :disabled='!selectedOptionId')
</template>
