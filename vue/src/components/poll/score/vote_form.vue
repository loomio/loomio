<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'
import { head, filter, map } from 'lodash'

export default
  props:
    stance: Object

  data: ->
    pollOptions: []
    stanceChoices: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @poll.pollOptions()

        @stanceChoices = map @pollOptions, (option) =>
            poll_option_id: option.id
            score: @stanceChoiceFor(option).score
  methods:
    submit: ->
      @stance.id = null
      @stance.stanceChoicesAttributes = @stanceChoices
      actionName = if @stance.isNew() then 'created' else 'updated'
      @stance.save()
      .then =>
        @stance.poll().clearStaleStances()
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
      .catch onError(@stance)

    stanceChoiceFor: (option) ->
      head(filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

  computed:
    poll: -> @stance.poll()
</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  .poll-score-vote-form__options
    .poll-score-vote-form__option(v-for='choice in stanceChoices', :key='choice.poll_option_id')
      v-subheader.poll-score-vote-form__option-label {{ optionFor(choice).name }}
      v-slider.poll-score-vote-form__score-slider(v-model='choice.score' :color="optionFor(choice).color" :thumb-color="optionFor(choice).color" :track-color="optionFor(choice).color" :height="4" :thumb-size="24" :thumb-label="(choice.score > 0) ? 'always' : true" :min="poll.customFields.min_score" :max="poll.customFields.max_score")
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
