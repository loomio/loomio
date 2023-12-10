<script lang="js">
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import Session        from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import PollService from '@/shared/services/poll_service';
import { mdiFlagCheckered } from '@mdi/js';

export default {
  props: {
    poll: Object
  },

  data() {
    return { mdiFlagCheckered };
  },

  methods: {
    showPanel() {
      return AbilityService.canSetPollOutcome(this.poll);
    },

    openOutcomeForm() {
      PollService.openSetOutcomeModal(this.poll);
    }
  }
};

</script>

<template lang="pug">
v-alert.my-4.poll-common-set-outcome-panel(
  :icon="mdiFlagCheckered"
  prominent
  outlined
  v-if="showPanel()"
  color="primary"
  elevation="3")
  v-row(align="center")
    v-col.grow
      span(v-t="{path: 'poll_common_set_outcome_panel.poll_type', args: {poll_type: poll.translatedPollType()}}")
    v-col.shrink
      v-btn.poll-common-set-outcome-panel__submit(color="primary" @click="openOutcomeForm()" v-t="'poll_common_set_outcome_panel.enter_outcome'")
</template>
