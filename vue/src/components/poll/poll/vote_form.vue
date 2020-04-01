<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { compact, sortBy, without } from 'lodash'
import { onError } from '@/shared/helpers/form'

export default
  props:
    stance: Object

  data: ->
    selectedOptionIds: compact @stance.pollOptionIds()
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (records) =>
        @pollOptions = @stance.poll().pollOptions() if @stance.poll()

  methods:
    submit: ->
      @stance.id = null
      @stance.stanceChoicesAttributes = @selectedOptionIds.map (id) =>
        poll_option_id: id
      actionName = if @stance.isNew() then 'created' else 'updated'
      @stance.save()
      .then =>
        @stance.poll().clearStaleStances()
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit('closeModal')
      .catch onError(@stance)

    orderedPollOptions: ->
      sortBy @pollOptions, 'name'

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
  v-card-actions.poll-common-form-actions
    v-spacer
    poll-common-show-results-button(v-if='stance.isNew()')
    v-btn.poll-common-vote-form__submit(:disabled='!selectedOptionIds.length' color="primary" @click='submit()', v-t="'poll_common.vote'")
</template>
