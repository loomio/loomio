<style lang="scss">
.poll-common-set-outcome-panel {
  margin-bottom: 16px;
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
  props:
    poll: Object
  methods:
    showPanel: ->
      !@poll.outcome() and AbilityService.canSetPollOutcome(@poll)

    openOutcomeForm: ->
      outcome = @poll.outcome() or
      Records.outcomes.build(pollId: @poll.id)
      @openPollOutcomeModal(outcome)
</script>

<template>
    <div v-if="showPanel()" class="poll-common-set-outcome-panel">
      <p v-t="'poll_common_set_outcome_panel.' + poll.pollType" class="lmo-hint-text"></p>
      <v-btn @click="openOutcomeForm()" v-t="'poll_common_set_outcome_panel.share_outcome'" :aria-label="$t('poll_common.set_outcome')" class="md-primary md-raised poll-common-set-outcome-panel__submit"></v-btn>
    </div>
</template>
