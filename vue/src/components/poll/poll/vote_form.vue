<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { compact, sortBy, without, isEqual, map } from 'lodash'

export default
  props:
    stance: Object

  data: ->
    selectedOptionIds: compact(@stance.pollOptionIds() || [parseInt(@$route.query.poll_option_id)])
    selectedOptionId: @stance.pollOptionIds()[0] || parseInt(@$route.query.poll_option_id)
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: (records) =>
        if @stance.poll().optionsDiffer(@pollOptions)
          @pollOptions = @stance.poll().pollOptionsForVoting() if @stance.poll()

  computed:
    reasonTooLong: ->
      !@stance.poll().allowLongReason && @stance.reason && @stance.reason.length > 500
    poll: -> @stance.poll()
    optionSelected: -> @selectedOptionIds.length or @selectedOptionId
    submitText: ->
      if @stance.castAt
        'poll_common.update_vote'
      else
        'poll_common.submit_vote'

  methods:
    submit: ->
      if @poll.multipleChoice
        @stance.stanceChoicesAttributes = @selectedOptionIds.map (id) =>
          poll_option_id: id
      else
        @stance.stanceChoicesAttributes = [{poll_option_id: @selectedOptionId}]
      actionName = if !@stance.castAt then 'created' else 'updated'
      @stance.save()
      .then =>
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit('closeModal')
      .catch => true

</script>

<template lang="pug">
.poll-poll-vote-form
  submit-overlay(:value="stance.processing")
  .mb-6(v-if="poll.multipleChoice")
    v-checkbox.poll-common-vote-form__button(v-for='option in pollOptions' :key='option.id' v-model="selectedOptionIds" :value="option.id" :label="option.name" hide-details :color="option.color")
  v-radio-group.mb-6(v-if="!poll.multipleChoice" v-model="selectedOptionId")
    v-radio.poll-common-vote-form__button(v-for='option in pollOptions' :key='option.id' :value="option.id" :label="option.name" hide-details :color="option.color")
  poll-common-add-option-button(:poll='stance.poll()')
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance')
  v-card-actions.poll-common-form-actions
    //- v-spacer
    v-btn.poll-common-vote-form__submit(block :disabled='!optionSelected || reasonTooLong' color="primary" @click='submit()' :loading="stance.processing")
      span(v-t="submitText")
</template>
