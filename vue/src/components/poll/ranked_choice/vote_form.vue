<style lang="scss">
@import 'variables';
.poll-ranked-choice-vote-form {
  .poll-common-vote-form__option {
    width: 100%;
    padding-right: 0;
    // box-shadow: $whiteframe-shadow-2dp;
    background: $card-background-color;
    &--selected {
      background: $item-highlight-color
    }
  }
  .poll-common-vote-form__border-chip {
    min-height: 36px;
  }
}

.poll-ranked-choice-vote-form__drag-handle {
  color: $border-color;
}

.poll-ranked-choice-vote-form__cutoff {
  padding-bottom: 16px !important;
  border-bottom: 1px solid $border-color
}

.poll-ranked-choice-vote-form__ordinal {
  margin-bottom: 16px;
}

</style>

<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import { submitStance }                    from '@/shared/helpers/form'

import _sortBy from 'lodash/sortBy'
import _find from 'lodash/find'
import _matchesProperty from 'lodash/matchesProperty'
import _take from 'lodash/take'
import _map from 'lodash/map'
import _findIndex from 'lodash/findIndex'

export default
  props:
    stance: Object
  data: ->
    numChoices: @stance.poll().customFields.minimum_stance_choices
    pollOptions: _sortBy @stance.poll().pollOptions(), (option) =>
      choice = _find(@stance.stanceChoices(), _matchesProperty('pollOptionId', option.id))
      -(choice or {}).score
  created: ->
    @submit = submitStance @, @stance,
      prepareFn: =>
        EventBus.$emit 'processing'
        @stance.id = null
        selected = _take @pollOptions, @numChoices
        @stance.stanceChoicesAttributes = _map selected, (option, index) =>
          poll_option_id: option.id
          score:         @numChoices - index
  methods:
    orderedPollOptions: ->
      _sortBy @pollOptions(), 'priority'

    setSelected: (option) ->
      @selectedOption = option

    selectedOptionIndex: ->
      _findIndex @pollOptions, @selectedOption

    isSelected: (option) ->
      @selectedOption == option

    swap: (fromIndex, toIndex) ->
      return unless fromIndex >= 0 and fromIndex < @pollOptions.length and
                    toIndex   >= 0 and toIndex   < @pollOptions.length
      @pollOptions[fromIndex]   = @pollOptions[toIndex]
      @pollOptions[toIndex]     = @selectedOption

</script>

<template>
    <div class="poll-ranked-choice-vote-form lmo-relative">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <poll-common-anonymous-helptext v-if="stance.poll().anonymous"></poll-common-anonymous-helptext>
      <p v-t="{ path: 'poll_ranked_choice_vote_form.helptext', args: { count: numChoices } }" class="lmo-hint-text"></p>
      <div sv-root="true" layout="row" class="lmo-flex">
        <ul md-list layout="column" class="lmo-flex">
          <li md-list-item v-for="(option, index) in orderedPollOptions" :key="option.id" class="poll-ranked-choice-vote-form__ordinal">
            <span v-if="index < numChoices">{{index+1}}</span>
          </li>
        </ul>
        <ul md-list layout="column" sv-part="pollOptions" class="lmo-flex lmo-flex__grow">
          <li md-list-item
            @click="setSelected(option)"
            sv-element="true"
            layout="row"
            :class="{'poll-common-vote-form__option--selected': isSelected(option)}"
            v-for="option in pollOptions"
            :key="option.id"
            class="poll-common-vote-form__option lmo-flex lmo-pointer lmo-flex__space-between"
          >
            <div :style="{'border-color': option.color}" class="poll-common-vote-form__option-name poll-common-vote-form__border-chip lmo-flex__grow">{{option.name}}</div>
            <i class="mdi mdi-drag poll-ranked-choice-vote-form__drag-handle"></i>
          </li>
        </ul>
      </div>
      <validation-errors :subject="stance" field="stanceChoices"></validation-errors>
      <poll-common-stance-reason :stance="stance"></poll-common-stance-reason>
      <div class="poll-common-form-actions lmo-flex lmo-flex__space-between">
        <poll-common-show-results-button v-if="stance.isNew()"></poll-common-show-results-button>
        <div v-if="!stance.isNew()"></div>
        <button @click="submit()" v-t="'poll_common.vote'" aria-label="$t( 'poll_poll_vote_form.vote')" class="md-primary md-raised poll-common-vote-form__submit"></button>
      </div>
    </div>
</template>
