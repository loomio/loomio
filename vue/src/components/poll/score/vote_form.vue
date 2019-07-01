<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import { submitStance }  from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

import { head, filter, map } from 'lodash'

export default
  mixins: [WatchRecords]
  props:
    stance: Object

  data: ->
    pollOptions: []
    stanceChoices: []

  created: ->
    @submit = submitStance @, @stance,
      prepareFn: =>
        @$emit 'processing'
        @stance.id = null
        @stance.stanceChoicesAttributes = @stanceChoices

    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @stance.poll().pollOptions()

        @stanceChoices = map @pollOptions, (option) =>
            poll_option_id: option.id
            score: @stanceChoiceFor(option).score
  methods:
    stanceChoiceFor: (option) ->
      head(filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  .poll-score-vote-form__options
    .poll-score-vote-form__option(v-for='choice in stanceChoices', :key='choice.poll_option_id')
      v-subheader.poll-score-vote-form__option-label {{ optionFor(choice).name }}
      v-slider.poll-score-vote-form__score-slider(v-model='choice.score' :color="optionFor(choice).color" :thumb-color="optionFor(choice).color" :track-color="optionFor(choice).color" :height="4" :thumb-size="24" :thumb-label="(choice.score > 0) ? 'always' : true" :min="0" :max="9")
        //- template(v-slot:append)
        //-   v-text-field.poll-score-vote-form__score-input(v-model='choice.score' class="mt-0 pt-0" hide-details single-line type="number" style="width: 60px")
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  v-card-actions.poll-common-form-actions
    poll-common-show-results-button(v-if='stance.isNew()')
    v-spacer
    v-btn.poll-common-vote-form__submit(color="primary" type='submit' v-t="'poll_common.vote'")
</template>
