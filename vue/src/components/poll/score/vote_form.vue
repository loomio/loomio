<style lang="scss">
.poll-score-vote-form__options{
}

.poll-score-vote-form__option {
  padding: 0 !important;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  display: flex;
}

.poll-score-vote-form__option-label-container {
  padding: 0 !important;
  display: flex;
  flex: 1;
  align-self: stretch;
  align-items: flex-start;
  justify-content: flex-start;
}

.poll-score-vote-form__option-label {
  padding: 0 !important;
}

.poll-score-vote-form__input-container {
  width: 90%;
  min-height: 48px;
  display: flex;
}

.poll-score-vote-form__score-input {
  margin-left: 4px;
  margin-right: 4px;
  order: 0 !important;
  text-align: center;
  position: relative;
  top: 4px;
}
</style>

<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

import { submitStance }  from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

import _head from 'lodash/head'
import _filter from 'lodash/filter'
import _map from 'lodash/map'

export default
  props:
    stance: Object
  data: ->
    vars: {}
  created: ->
    @setStanceChoices()
    EventBus.$on 'pollOptionsAdded', @setStanceChoices
    @submit = submitStance @, @stance,
      prepareFn: =>
        @$emit 'processing'
        @stance.id = null
        @stance.stanceChoicesAttributes = @stanceChoices
  # mounted: ->
  #   submitOnEnter @, element: @$el
  methods:
    stanceChoiceFor: (option) ->
      _head(_filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    setStanceChoices: ->
      @stanceChoices = _map @stance.poll().pollOptions(), (option) =>
        poll_option_id: option.id
        score: @stanceChoiceFor(option).score


</script>

<template>
    <form @submit.prevent="submit()" class="poll-score-vote-form">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <ul md-list class="poll-score-vote-form__options">
        <div v-for="choice in stanceChoices" :key="choice.poll_option_id" class="poll-score-vote-form__option">
          <div class="poll-score-vote-form__option-label-container">
            <div class="poll-score-vote-form__option-label">{{ optionFor(choice).name }}</div>
          </div>
          <div md-slider-container class="poll-score-vote-form__input-container">
            <!-- <md-slider min="0" max="9" ng-model="choice.score" aria-label="score" class="poll-score-vote-form__score-slider"></md-slider> -->
            <input type="number" v-model="choice.score" aria-label="score" aria-controls="score-slider" class="poll-score-vote-form__score-input">
          </div>
        </div>
      </ul>
      <validation-errors :subject="stance" field="stanceChoices"></validation-errors>
      <poll-common-stance-reason :stance="stance"></poll-common-stance-reason>
      <div class="poll-common-form-actions lmo-flex lmo-flex__space-between">
        <poll-common-show-results-button v-if="stance.isNew()"></poll-common-show-results-button>
        <div v-if="!stance.isNew()"></div>
        <button type="submit" v-t="'poll_common.vote'" aria-label="$t('poll_poll_vote_form.vote')" class="md-primary md-raised poll-common-vote-form__submit"></button>
      </div>
    </form>
</template>
