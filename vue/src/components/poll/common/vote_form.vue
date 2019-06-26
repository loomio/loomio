<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import { submitOnEnter } from '@/shared/helpers/keyboard'
import { submitStance }  from '@/shared/helpers/form'
import { buttonStyle }   from '@/shared/helpers/style'

export default
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
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous' :poll="stance.poll()")
  v-layout(justify-space-around)
    v-btn.poll-common-vote-form__button.mr-2(fab x-large :elevation="0" text md-colors='mdColors(option)' v-for='option in orderedPollOptions()' :key='option.id' @click='select(option)')
      //- v-badge(overlap)
      //-   template(v-slot:badge)
      //-     span.poll-common-vote-form__chosen-option--name(v-t="'poll_' + stance.poll().pollType + '_options.' + option.name")
      v-avatar(size="52px")
        img(:src="'/img/' + option.name + '.svg'")
      // <md-tooltip md-delay="750" class="poll-common-vote-form__tooltip"><span translate="poll_{{stance.poll().pollType}}_options.{{option.name}}_meaning"></span></md-tooltip>
  poll-common-stance-reason.animated(:stance='stance', v-show='selectedOptionId', v-if='stance')
  v-card-actions
    v-spacer
    poll-common-show-results-button(v-if='stance.isNew()')
    v-btn.poll-common-vote-form__submit(color="primary", @click='submit()', v-t="'poll_common.vote'", :disabled='!selectedOptionId')
</template>
