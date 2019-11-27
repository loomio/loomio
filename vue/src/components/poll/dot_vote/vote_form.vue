<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import { submitStance }  from '@/shared/helpers/form'

import { sum, map, head, filter, without } from 'lodash'

export default
  mixins: [WatchRecords]
  props:
    stance: Object

  data: ->
    pollOptions: []
    stanceChoices: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @stance.poll().pollOptions()
        @stanceChoices = map @pollOptions, (option) =>
          poll_option_id: option.id
          score: @stanceChoiceFor(option).score
    @submit = submitStance @, @stance,
      prepareFn: =>
        EventBus.$emit 'processing'
        @stance.id = null
        return unless sum(map(@stanceChoices, 'score')) > 0
        @stance.stanceChoicesAttributes = @stanceChoices

  methods:
    rulesForChoice: (choice) ->
      [(v) => (v <= @maxForChoice(choice)) || @$t('poll_dot_vote_vote_form.too_many_dots')]

    percentageFor: (choice) ->
      max = dotsPerPerson
      return unless max > 0
      "#{100 * choice.score / max}% 100%"

    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"

    styleData: (choice) ->
      option = @optionFor(choice)
      'border-color': option.color
      'background-image': @backgroundImageFor(option)
      'background-size': @percentageFor(choice)

    stanceChoiceFor: (option) ->
      head(filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    adjust: (choice, amount) ->
      choice.score += amount

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    maxForChoice: (choice) ->
      @dotsPerPerson - sum(map(without(@stanceChoices, choice), 'score'))

  computed:
    dotsRemaining: ->
      @dotsPerPerson - sum(map(@stanceChoices, 'score'))

    dotsPerPerson: ->
      @stance.poll().customFields.dots_per_person

</script>

<template lang="pug">
.poll-dot-vote-vote-form
  v-subheader.poll-dot-vote-vote-form__dots-remaining(v-t="{ path: 'poll_dot_vote_vote_form.dots_remaining', args: { count: dotsRemaining } }")
  .poll-dot-vote-vote-form__options
    .poll-dot-vote-vote-form__option(v-for='choice in stanceChoices', :key='choice.poll_option_id')
      v-subheader.poll-dot-vote-vote-form__option-label {{ optionFor(choice).name }}
      v-layout(row align-center)
        v-slider.poll-dot-vote-vote-form__slider.mr-4(v-model='choice.score' :rules="rulesForChoice(choice)" :color="optionFor(choice).color" :thumb-color="optionFor(choice).color" :track-color="optionFor(choice).color" :height="4" :thumb-size="24" :thumb-label="(choice.score > 0) ? 'always' : true" :min="0" :max="dotsPerPerson" :readonly="false")
    validation-errors(:subject='stance', field='stanceChoices')

  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  .poll-common-form-actions
    poll-common-show-results-button(v-if='stance.isNew()')
    v-spacer
    v-btn.poll-common-vote-form__submit(color="primary" :disabled="dotsRemaining < 0" @click="submit()" v-t="'poll_common.vote'")
</template>
