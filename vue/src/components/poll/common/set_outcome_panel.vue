<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import PollModalMixin from '@/mixins/poll_modal'
import Session        from '@/shared/services/session'

export default
  mixins: [PollModalMixin]
  props:
    poll: Object
  methods:
    showPanel: ->
      !@poll.outcome() and AbilityService.canSetPollOutcome(@poll)

    openOutcomeForm: ->
      outcome = @poll.outcome() or
      Records.outcomes.build
        pollId: @poll.id
        statementFormat: Session.defaultFormat()
      @openPollOutcomeModal(outcome)

</script>

<template lang="pug">
v-sheet.pa-4.my-4.poll-common-set-outcome-panel(color="primary lighten-5" elevation="2" v-if="showPanel()")
  p.lmo-hint-text(v-html="$t('poll_common_set_outcome_panel.' + poll.pollType)")
  v-layout(justify-space-around)
    v-btn.poll-common-set-outcome-panel__submit( color="accent" @click="openOutcomeForm()" v-t="'poll_common_set_outcome_panel.enter_outcome'")
</template>
