<style>
.current-polls-card__start-poll {
  margin: 0;
}

.current-polls-card__title {
  margin-bottom: 8px;
}
</style>

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
</script>

<template>
    <div v-if="polls().length" class="current-polls-card lmo-card">
      <h2 v-t="'current_polls_card.title'" class="lmo-card-heading lmo-truncate-text"></h2>
      <div class="current-polls-card__polls">
        <div v-if="!canStartPoll() && !polls().length" v-t="'current_polls_card.no_polls'" class="current-polls-card__no-polls lmo-hint-text"></div>
        <poll-common-preview :poll="poll" v-for="poll in polls()" :key="poll.id"></poll-common-preview>
      </div>
      <!-- <loading v-if="fetchRecordsExecuting"></loading> -->
    </div>
</template>
