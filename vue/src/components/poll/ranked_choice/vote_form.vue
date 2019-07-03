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
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  .poll-common-form-actions.lmo-flex.lmo-flex__space-between
    poll-common-show-results-button(v-if='stance.isNew()')
    div(v-if='!stance.isNew()')
    v-btn.md-primary.md-raised.poll-common-vote-form__submit(@click='submit()', v-t="'poll_common.vote'", aria-label="$t( 'poll_poll_vote_form.vote')")
</template>
