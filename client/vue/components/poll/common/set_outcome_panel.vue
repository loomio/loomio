<style lang="scss">
.poll-common-set-outcome-panel {
  margin-bottom: 16px;
}
</style>

<script lang="coffee">
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

module.exports =
  props:
    poll: Object
  methods:
    showPanel: ->
      !@poll.outcome() and AbilityService.canSetPollOutcome(@poll)

    openOutcomeForm: ->
      ModalService.open 'PollCommonOutcomeModal', outcome: =>
        @poll.outcome() or
        Records.outcomes.build(pollId: @poll.id)
</script>

<template>
    <div v-if="showPanel()" class="poll-common-set-outcome-panel">
      <p v-t="'poll_common_set_outcome_panel.' + poll.pollType" class="lmo-hint-text"></p>
      <!-- <md-dialog-actions>
        <md-button ng-click="openOutcomeForm()" translate="poll_common_set_outcome_panel.share_outcome" aria-label="{{poll_common.set_outcome | translate}}" class="md-primary md-raised poll-common-set-outcome-panel__submit"></md-button>
      </md-dialog-actions> -->
    </div>
</template>
