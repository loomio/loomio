<style lang="scss">
@import 'variables';
.poll-dot-vote-vote-form__option{
  padding: 0 !important;
}

.poll-dot-vote-vote-form__input-container {
  width: 100%;
  min-height: 48px;
  display: flex;
}

.poll-dot-vote-vote-form__dot-input {
  width: 35px !important;
  text-align: center;
  &::-webkit-inner-spin-button, &::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }
  &[type=number] {
    -moz-appearance: textfield;
  }
}

.poll-dot-vote-vote-form__dot-button {
  background: none;
  border: 0;
  color: $grey-on-white;
  width: 32px;
  height: 32px;
  &[disabled] {
    opacity: 0;
  }
}

.poll-dot-vote-vote-form__dot-input-field {
  display: flex;
  justify-content: flex-end;
  text-align: center;
  min-height: 48px;
  margin-left: auto;
  margin-top: 16px;
}

.poll-dot-vote-vote-form__dot-input {
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
import WatchRecords from '@/mixins/watch_records'

import { submitStance }  from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

import _sum from 'lodash/sum'
import _map from 'lodash/map'
import _head from 'lodash/head'
import _filter from 'lodash/filter'

export default
  mixins: [WatchRecords]
  props:
    stance: Object

  data: ->
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @stance.poll().pollOptions()
    @submit = submitStance @, @stance,
      prepareFn: =>
        EventBus.$emit 'processing'
        @stance.id = null
        return unless _sum(_map(@stanceChoices, 'score')) > 0
        @stance.stanceChoicesAttributes = @stanceChoices
    # submitOnEnter @, element: @$el

  methods:
    percentageFor: (choice) ->
      max = @stance.poll().customFields.dots_per_person
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
      _head(_filter(@stance.stanceChoices(), (choice) =>
        choice.pollOptionId == option.id
        ).concat({score: 0}))

    adjust: (choice, amount) ->
      choice.score += amount

    optionFor: (choice) ->
      Records.pollOptions.find(choice.poll_option_id)

    dotsRemaining: ->
      @stance.poll().customFields.dots_per_person - _sum(_map(@stanceChoices, 'score'))

    tooManyDots: ->
      @dotsRemaining() < 0

  computed:
    stanceChoices: ->
      _map @pollOptions, (option) =>
        poll_option_id: option.id
        score: @stanceChoiceFor(option).score
</script>

<template lang="pug">
.poll-dot-vote-vote-form
  v-subheader(v-t="'poll_common.your_response'")
  .lmo-hint-text
    .poll-dot-vote-vote-form__too-many-dots(v-if='tooManyDots()', v-t="'poll_dot_vote_vote_form.too_many_dots'")
    .poll-dot-vote-vote-form__dots-remaining(v-if='!tooManyDots()', v-t="{ path: 'poll_dot_vote_vote_form.dots_remaining', args: { count: dotsRemaining() } }")
  v-list.poll-common-vote-form__options
    v-list-item.poll-dot-vote-vote-form__option.poll-common-vote-form__option(v-for='choice in stanceChoices', :key='choice.poll_option_id')
      v-layout
        p.poll-dot-vote-vote-form__chosen-option--name.poll-common-vote-form__border-chip.poll-common-bar-chart__bar(:style='styleData(choice)') {{ optionFor(choice).name }}
        v-layout
          v-btn.poll-dot-vote-vote-form__dot-button(type='button', @click='adjust(choice, -1)', :disabled='choice.score == 0')
            .mdi.mdi-24px.mdi-minus-circle-outline
          v-text-field(type='number', v-model='choice.score', min='0', step='1')
          v-btn.poll-dot-vote-vote-form__dot-button(type='button', @click='adjust(choice, 1)', :disabled='dotsRemaining() == 0')
            .mdi.mdi-24px.mdi-plus-circle-outline
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  .poll-common-form-actions.lmo-flex.lmo-flex__space-between
    poll-common-show-results-button(v-if='stance.isNew()')
    div(v-if='!stance.isNew()')
    button.md-primary.md-raised.poll-common-vote-form__submit(type='button', @click="submit()", :disabled='tooManyDots()', v-t="'poll_common.vote'", aria-label="$t('poll_poll_vote_form.vote')")
</template>
