<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import { submitStance }  from '@/shared/helpers/form'
import { optionColors, optionImages } from '@/shared/helpers/poll'

export default
  props:
    stance: Object
  data: ->
    selectedOptionId: @stance.pollOptionId()
    optionColors: optionColors()
    optionImages: optionImages()
  mounted: ->
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

    style: (option) ->
      if @selectedOptionId && @selectedOptionId != option.id
        {opacity: 0.3}

    select: (option) ->
      @selectedOptionId = option.id
      @$nextTick => EventBus.$emit 'focusTextarea'

  computed:
    optionGroups: ->
      options = @orderedPollOptions()
      length = options.length
      if length == 4
        [[options[0], options[1]], [options[2], options[3]]]
      else
        [options]
</script>

<template lang="pug">
.poll-common-vote-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="stance.processing")
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous' :poll="stance.poll()")
  v-layout(wrap)
    v-layout.mb-4(justify-space-around v-for='(optionGroup, index) in optionGroups' :key="index")
      v-btn.poll-common-vote-form__button.poll-proposal-vote-form__button(color="accent" :style="style(option)" text outlined v-for='option in optionGroup' :key='option.id' @click='select(option)')
        v-layout(column align-center)
          //- v-badge(overlap)
          //-   template(v-slot:badge)
          //-     span.poll-common-vote-form__chosen-option--name(v-t="'poll_' + stance.poll().pollType + '_options.' + option.name")
          v-avatar(size="52px")
            img(:src="'/img/' + optionImages[option.name] + '.svg'")
          span {{option.name}}
          //- // <md-tooltip md-delay="750" class="poll-common-vote-form__tooltip"><span translate="poll_{{stance.poll().pollType}}_options.{{option.name}}_meaning"></span></md-tooltip>
  poll-common-stance-reason.animated(:stance='stance', v-show='selectedOptionId', v-if='stance')
  v-card-actions
    v-spacer
    poll-common-show-results-button(v-if='stance.isNew()')
    v-btn.poll-common-vote-form__submit(color="primary", @click='submit()', v-t="'poll_common.vote'" :disabled='!selectedOptionId')
</template>
<style lang="css">
.poll-proposal-vote-form__button {
  height: 112px !important;
}
</style>
