<style lang="scss">
// .poll-score-vote-form__options{
// }
//
// .poll-score-vote-form__option {
//   padding: 0 !important;
//   flex-direction: column;
//   align-items: center;
//   justify-content: center;
//   display: flex;
// }
//
// .poll-score-vote-form__option-label-container {
//   padding: 0 !important;
//   display: flex;
//   flex: 1;
//   align-self: stretch;
//   align-items: flex-start;
//   justify-content: flex-start;
// }
//
// .poll-score-vote-form__option-label {
//   padding: 0 !important;
// }
//
// .poll-score-vote-form__input-container {
//   width: 90%;
//   min-height: 48px;
//   display: flex;
// }
//
// .poll-score-vote-form__score-input {
//   margin-left: 4px;
//   margin-right: 4px;
//   order: 0 !important;
//   text-align: center;
//   position: relative;
//   top: 4px;
// }
</style>

<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import { submitStance }  from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

import _head from 'lodash/head'
import _filter from 'lodash/filter'
import _map from 'lodash/map'

export default
  mixins: [WatchRecords]
  props:
    stance: Object
  data: ->
    pollOptions: []
    vars: {}
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
  methods:
    stanceChoiceFor: (option) ->
      _head(_filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

  computed:
    stanceChoices: ->
      _map @pollOptions, (option) =>
        poll_option_id: option.id
        score: @stanceChoiceFor(option).score

</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  h3.lmo-card-subheading(v-t="'poll_common.your_response'")
  .poll-score-vote-form__options
    .poll-score-vote-form__option(v-for='choice in stanceChoices', :key='choice.poll_option_id')
      v-subheader.poll-score-vote-form__option-label {{ optionFor(choice).name }}
      v-slider.poll-score-vote-form__score-slider(v-model='choice.score' :color="optionFor(choice).color" :thumb-color="optionFor(choice).color" :track-color="optionFor(choice).color" :height="4" :thumb-size="24" :thumb-label="(choice.score > 0) ? 'always' : true" :min="0" :max="9")
        //- template(v-slot:append)
        //-   v-text-field.poll-score-vote-form__score-input(v-model='choice.score' class="mt-0 pt-0" hide-details single-line type="number" style="width: 60px")
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  .poll-common-form-actions.lmo-flex.lmo-flex__space-between
    poll-common-show-results-button(v-if='stance.isNew()')
    div(v-if='!stance.isNew()')
    v-btn.md-primary.md-raised.poll-common-vote-form__submit(type='submit', v-t="'poll_common.vote'", aria-label="$t('poll_poll_vote_form.vote')")
</template>
