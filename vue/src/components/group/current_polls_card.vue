<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import { applyLoadingFunction } from '@/shared/helpers/apply'
import { take } from 'lodash'

export default
  props:
    model: Object
  created: ->
    applyLoadingFunction @, 'fetchRecords'
    @init()
  methods:
    init: ->
      Records.polls.fetchFor(@model, status: 'active')
      Records.view
        name: "currentPollsFor#{@model.id}"
        collections: ['polls']
        query: (store) =>
          @polls = take @model.activePolls(), (@limit or 50)

    startPoll: ->
      ModalService.open 'PollCommonStartModal', poll: =>
        if @model.isA('discussion')
          Records.polls.build(discussionId: @model.id, groupId: @model.groupId)
        else if @model.isA('group')
          Records.polls.build(groupId: @model.id)

    canStartPoll: ->
      AbilityService.canStartPoll(@model.group())
</script>

<template lang="pug">
v-card.current-polls-card(v-if='polls.length')
  v-subheader(v-t="'current_polls_card.title'")
  .current-polls-card__no-polls.lmo-hint-text(v-if='!canStartPoll() && polls.length == 0', v-t="'current_polls_card.no_polls'")
  v-list(v-if='polls.length')
    poll-common-preview(:poll='poll', v-for='poll in polls', :key='poll.id')
  // <loading v-if="fetchRecordsExecuting"></loading>
</template>
