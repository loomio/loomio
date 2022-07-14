<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import Records   from '@/shared/services/records'
import { compact, sortBy, without, isEqual, map } from 'lodash'

export default
  props:
    stance: Object

  data: ->
    selectedOptionIds: compact((@stance.pollOptionIds().length && @stance.pollOptionIds()) || [parseInt(@$route.query.poll_option_id)])
    selectedOptionId: @stance.pollOptionIds()[0] || parseInt(@$route.query.poll_option_id)
    options: []

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: (records) =>
        if @poll.optionsDiffer(@options)
          @options = @poll.pollOptionsForVoting() if @poll

  computed:
    singleChoice: -> @poll.singleChoice()
    hasOptionIcon: -> @poll.config().has_option_icon
    poll: -> @stance.poll()
    optionSelected: -> @selectedOptionIds.length or @selectedOptionId
    submitText: ->
      if @stance.castAt
        'poll_common.update_vote'
      else
        'poll_common.submit_vote'

  methods:
    submit: ->
      if @singleChoice
        @stance.stanceChoicesAttributes = [{poll_option_id: @selectedOptionId}]
      else
        @stance.stanceChoicesAttributes = @selectedOptionIds.map (id) =>
          poll_option_id: id
      actionName = if !@stance.castAt then 'created' else 'updated'
      @stance.save()
      .then =>
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit('closeModal')
      .catch => true

    isSelected: (option) ->
      if @singleChoice 
        @selectedOptionId == option.id
      else
        @selectedOptionIds.includes(option.id)

    classes: (option) ->
      if @optionSelected
        if @isSelected(option)
          ['elevation-2']
        else
          ['poll-common-vote-form__button--not-selected']
</script>

<template lang="pug">
form.poll-common-vote-form(@keyup.ctrl.enter="submit()", @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="stance.processing")

  v-sheet.poll-common-vote-form__button.mb-2.rounded(
    outlined
    :style="(isSelected(option) && {'border-color': option.color}) || {}"
    v-for='option in options'
    :key='option.id'
    :class="classes(option)"
  )
    label
      input(
        v-if="singleChoice"
        v-model="selectedOptionId"
        :value="option.id"
        :aria-label="option.optionName()"
        type="radio"
        name="name"
      )
      input(
        v-if="!singleChoice"
        v-model="selectedOptionIds"
        :value="option.id"
        :aria-label="option.optionName()"
        type="checkbox"
        name="name"
      )
      v-list-item
        v-list-item-icon
          template(v-if="hasOptionIcon")
            v-avatar(size="48")
              img(aria-hidden="true", :src="'/img/' + option.icon + '.svg'")
          template(v-else)
            v-icon(v-if="singleChoice && !isSelected(option)", :color="option.color") mdi-radiobox-blank
            v-icon(v-if="singleChoice && isSelected(option)", :color="option.color") mdi-radiobox-marked
            v-icon(v-if="!singleChoice && !isSelected(option)", :color="option.color") mdi-checkbox-blank-outline
            v-icon(v-if="!singleChoice && isSelected(option)", :color="option.color") mdi-checkbox-marked
        v-list-item-content
          v-list-item-title {{option.optionName()}}
          v-list-item-subtitle {{option.meaning}}

  poll-common-stance-reason(:stance='stance', :selectedOptionId="selectedOptionId")
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      @click='submit()'
      :disabled='!optionSelected'
      :loading="stance.processing"
      color="primary"
      block
    )
      span(v-t="submitText")
</template>
<style lang="sass">
.poll-common-vote-form__button--not-selected
  opacity: 0.33 !important

.poll-common-vote-form__button label
  cursor: pointer
  input
    position: absolute
    opacity: 0
    width: 0
    height: 0

.poll-common-vote-form__button
  &:hover
    border: 1px solid var(--v-primary-base)

</style>
