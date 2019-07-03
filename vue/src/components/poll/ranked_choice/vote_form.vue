<style lang="scss">
// @import 'variables';
// .poll-ranked-choice-vote-form {
//   .poll-common-vote-form__option {
//     width: 100%;
//     padding-right: 0;
//     // box-shadow: $whiteframe-shadow-2dp;
//     background: $card-background-color;
//     &--selected {
//       background: $item-highlight-color
//     }
//   }
//   .poll-common-vote-form__border-chip {
//     min-height: 36px;
//   }
// }
//
// .poll-ranked-choice-vote-form__drag-handle {
//   color: $border-color;
// }
//
// .poll-ranked-choice-vote-form__cutoff {
//   padding-bottom: 16px !important;
//   border-bottom: 1px solid $border-color
// }
//
// .poll-ranked-choice-vote-form__ordinal {
//   margin-bottom: 16px;
// }

</style>

<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'
import { submitStance }                    from '@/shared/helpers/form'

import _sortBy from 'lodash/sortBy'
import _find from 'lodash/find'
import _matchesProperty from 'lodash/matchesProperty'
import _take from 'lodash/take'
import _map from 'lodash/map'
import _findIndex from 'lodash/findIndex'

export default
  mixins: [WatchRecords]
  props:
    stance: Object
  data: ->
    pollOptions: []
    numChoices: @stance.poll().customFields.minimum_stance_choices

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @sortPollOptions(@stance.poll().pollOptions())

    @submit = submitStance @, @stance,
      prepareFn: =>
        EventBus.$emit 'processing'
        @stance.id = null


        selected = _take @pollOptions, @numChoices
        @stance.stanceChoicesAttributes = _map selected, (option, index) =>
          poll_option_id: option.id
          score:         @numChoices - index


  methods:
    # setSelected: (option) ->
    #   @selectedOption = option
    #
    # selectedOptionIndex: ->
    #   _findIndex @pollOptions, @selectedOption
    #
    # isSelected: (option) ->
    #   @selectedOption == option
    #
    # swap: (fromIndex, toIndex) ->
    #   return unless fromIndex >= 0 and fromIndex < @pollOptions.length and
    #                 toIndex   >= 0 and toIndex   < @pollOptions.length
    #   @pollOptions[fromIndex]   = @pollOptions[toIndex]
    #   @pollOptions[toIndex]     = @selectedOption

    sortPollOptions: (pollOptions) ->
      optionsByPriority = _sortBy pollOptions, 'priority'
      _sortBy optionsByPriority, (option) => -@scoreFor(option)

    scoreFor: (option) ->
      choice = _find(@stance.stanceChoices(), _matchesProperty('pollOptionId', option.id))
      (choice or {}).score

</script>

<template lang='pug'>
.poll-ranked-choice-vote-form.lmo-relative
  h3.lmo-card-subheading(v-t="'poll_common.your_response'")
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous')
  p.lmo-hint-text(v-t="{ path: 'poll_ranked_choice_vote_form.helptext', args: { count: numChoices } }")

  sortable-list(v-model="pollOptions")
    sortable-item(v-for="(option, index) in pollOptions" :index="index" :key="option.id" :item="option")
      | {{index+1}}
      space
      v-chip.mr-2(:color="option.color" :index="index" :key="index") {{ option.name }}

  //- .lmo-flex(sv-root='true', layout='row')
  //-   ul.lmo-flex(md-list='', layout='column')
  //-     li.poll-ranked-choice-vote-form__ordinal(md-list-item='', v-for='(option, index) in orderedPollOptions', :key='option.id')
  //-       span(v-if='index < numChoices') {{index+1}}
  //-   ul.lmo-flex.lmo-flex__grow(md-list='', layout='column', sv-part='pollOptions')
  //-     li.poll-common-vote-form__option.lmo-flex.lmo-pointer.lmo-flex__space-between(md-list-item='', @click='setSelected(option)', sv-element='true', layout='row', :class="{'poll-common-vote-form__option--selected': isSelected(option)}", v-for='option in pollOptions', :key='option.id')
  //-       .poll-common-vote-form__option-name.poll-common-vote-form__border-chip.lmo-flex__grow(:style="{'border-color': option.color}") {{option.name}}
  //-       i.mdi.mdi-drag.poll-ranked-choice-vote-form__drag-handle



  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  .poll-common-form-actions.lmo-flex.lmo-flex__space-between
    poll-common-show-results-button(v-if='stance.isNew()')
    div(v-if='!stance.isNew()')
    v-btn.md-primary.md-raised.poll-common-vote-form__submit(@click='submit()', v-t="'poll_common.vote'", aria-label="$t( 'poll_poll_vote_form.vote')")
</template>
