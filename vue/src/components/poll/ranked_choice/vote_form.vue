<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { sortBy, find, matchesProperty, take, map, isEqual, each } from 'lodash'

export default
  props:
    stance: Object
  data: ->
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: (records) =>
        if @stance.poll().optionsDiffer(@pollOptions)
          @pollOptions = @sortPollOptions()

  methods:
    submit: ->
      selected = take @pollOptions, @numChoices
      @stance.stanceChoicesAttributes = map selected, (option, index) =>
        poll_option_id: option.id
        score:         @numChoices - index
      actionName = if !@stance.castAt then 'created' else 'updated'
      @stance.save()
      .then =>
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit "closeModal"
      .catch => true

    sortPollOptions: ->
      if @stance && @stance.castAt
        sortBy @stance.poll().pollOptions(), (o) => -@stance.scoreFor(o)
      else
        @stance.poll().pollOptionsForVoting()

  computed:
    numChoices: -> @stance.poll().customFields.minimum_stance_choices
    reasonTooLong: ->
      !@stance.poll().allowLongReason && @stance.reason && @stance.reason.length > 500

</script>

<template lang='pug'>
.poll-ranked-choice-vote-form.lmo-relative
  p.text--secondary(v-t="{ path: 'poll_ranked_choice_vote_form.helptext', args: { count: numChoices } }")
  sortable-list(v-model="pollOptions")
    sortable-item(v-for="(option, index) in pollOptions" :index="index" :key="option.id" :item="option")
      v-icon(style="cursor: pointer") mdi-drag
      span(v-if="index+1 <= numChoices") {{index+1}}
      space
      v-chip.mr-2(:color="option.color" :index="index" :key="index") {{ option.name }}
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-add-option-button(:poll='stance.poll()')
  poll-common-stance-reason(:stance='stance')
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-vote-form__submit(:disabled="reasonTooLong" color="primary" @click='submit()' :loading="stance.processing")
      span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>
