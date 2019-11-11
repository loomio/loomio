<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import { submitStance }  from '@/shared/helpers/form'

import { compact, sortBy, without } from 'lodash'

export default
  mixins: [WatchRecords]
  props:
    stance: Object

  data: ->
    selectedOptionIds: compact @stance.pollOptionIds()
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @stance.poll().pollOptions()

    @submit = submitStance @, @stance,
      prepareFn: =>
        @$emit 'processing'
        @stance.id = null
        @stance.stanceChoicesAttributes = @selectedOptionIds.map (id) =>
          poll_option_id: id

  methods:
    orderedPollOptions: ->
      sortBy @pollOptions, 'priority'

    select: (option) ->
      if @isSelected(option)
        @selectedOptionIds = without(@selectedOptionIds, option.id)
      else
        if @stance.poll().multipleChoice
          @selectedOptionIds.push option.id
        else
          @selectedOptionIds = [option.id]
      @$nextTick => @$emit 'focusTextarea'

    isSelected: (option) ->
      @selectedOptionIds.includes(option.id)

</script>

<template lang="pug">
.poll-poll-vote-form
  submit-overlay(:value="stance.processing")
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous' :poll="stance.poll()")
  v-list(column)
    v-list-item.poll-common-vote-form__button(align-center @click='select(option)' v-for='option in orderedPollOptions()' :key='option.id')
      v-list-item-title
        v-chip.mr-2(:color="option.color") {{ option.name }}
        v-icon(v-if="isSelected(option)" color="accent") mdi-check
  poll-common-add-option-button(:poll='stance.poll()')
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason.animated(:stance='stance' v-show='selectedOptionIds.length')
  v-card-actions
    poll-common-show-results-button(v-show='!selectedOptionIds.length' v-if='stance.isNew()')
    v-spacer
    v-btn.poll-common-vote-form__submit(v-show='selectedOptionIds.length' color="primary" @click='submit()', v-t="'poll_common.vote'")
</template>
