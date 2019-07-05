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

<template lang="pug">
.poll-common-set-outcome-panel(v-if="showPanel()")
  p.lmo-hint-text(v-html="$t('poll_common_set_outcome_panel.' + poll.pollType)")
  v-layout(justify-space-around)
    v-btn.poll-common-set-outcome-panel__submit( color="primary" @click="openOutcomeForm()" v-t="'poll_common_set_outcome_panel.share_outcome'")
</template>
