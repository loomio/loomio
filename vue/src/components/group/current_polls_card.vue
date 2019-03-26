<script lang="coffee">
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

module.exports =
  props:
    model: Object
  created: ->
    applyLoadingFunction @, 'fetchRecords'
    @fetchRecords()
  methods:
    fetchRecords: ->
      Records.polls.fetchFor(@model, status: 'active')
    polls: ->
      _.take @model.activePolls(), (@limit or 50)

    startPoll: ->
      ModalService.open 'PollCommonStartModal', poll: =>
        if @model.isA('discussion')
          Records.polls.build(discussionId: @model.id, groupId: @model.groupId)
        else if @model.isA('group')
          Records.polls.build(groupId: @model.id)

    canStartPoll: ->
      AbilityService.canStartPoll(@model.group())
  computed:
    empty: ->
      @polls().length == 0
</script>

<template lang="pug">
v-card.current-polls-card(v-if='polls().length')
  v-subheader(v-t="'current_polls_card.title'")
  .current-polls-card__no-polls.lmo-hint-text(v-if='!canStartPoll() && empty', v-t="'current_polls_card.no_polls'")
  v-list(v-if='!empty')
    poll-common-preview(:poll='poll', v-for='poll in polls()', :key='poll.id')
  // <loading v-if="fetchRecordsExecuting"></loading>

</template>
