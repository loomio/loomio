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
    poll: -> @stance.poll()
    numChoices: -> @stance.poll().minimumStanceChoices
</script>

<template lang='pug'>
.poll-ranked-choice-vote-form.lmo-relative
  p.text--secondary(v-t="{ path: 'poll_ranked_choice_vote_form.helptext', args: { count: numChoices } }")
  sortable-list(v-model="pollOptions" lock-axis="y" axis="y" append-to=".app-is-booted")
    sortable-item(
      v-for="(option, index) in pollOptions"
      :index="index"
      :key="option.id"
      :item="option"
    )
      v-sheet.mb-2.rounded.poll-ranked-choice-vote-form__option(outlined :style="{'border-color': option.color}")
        v-list-item
          v-list-item-icon
            v-icon(style="cursor: pointer", :color="option.color") mdi-drag
          v-list-item-content
            v-list-item-title {{option.name}}
            v-list-item-subtitle {{option.meaning}}
          v-list-item-action
            span(style="font-size: 1.4rem" v-if="index+1 <= numChoices") # {{index+1}}

  validation-errors(:subject='stance' field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      :disabled="!poll.isVotable()"
      @click='submit()'
      :loading="stance.processing"
      color="primary"
    )
      span(v-t="stance.castAt? 'poll_common.update_vote' : 'poll_common.submit_vote'")
</template>

<style lang="sass">
.poll-ranked-choice-vote-form__option
  user-select: none

.app-is-booted > .sortable-list-item
  z-index: 10000
</style>
