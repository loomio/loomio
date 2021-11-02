<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import Session        from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'

export default
  props:
    poll: Object

  methods:
    showPanel: ->
      AbilityService.canSetPollOutcome(@poll)

    openOutcomeForm: ->
      outcome = Records.outcomes.build
        pollId: @poll.id
        groupId: @poll.groupId
        statementFormat: Session.defaultFormat()
      EventBus.$emit 'openModal',
        component: 'PollCommonOutcomeModal'
        props:
          outcome: outcome

</script>

<template lang="pug">
v-alert.my-4.poll-common-set-outcome-panel(
  icon="mdi-flag-checkered"
  prominent
  outlined
  v-if="showPanel()"
  color="primary"
  elevation="3")
  v-row(align="center")
    v-col.grow
      span(v-html="$t('poll_common_set_outcome_panel.' + poll.pollType)")
    v-col.shrink
      v-btn.poll-common-set-outcome-panel__submit(color="primary" @click="openOutcomeForm()" v-t="'poll_common_set_outcome_panel.enter_outcome'")
</template>
