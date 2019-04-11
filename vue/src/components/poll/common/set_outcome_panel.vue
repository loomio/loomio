<style lang="scss">
.poll-common-set-outcome-panel {
  margin-bottom: 16px;
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'

export default
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
