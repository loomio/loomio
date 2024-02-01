<script lang="js">
import EventBus from '@/shared/services/event_bus';
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';

export default {
  props: {
    close: Function,
    model: Object
  },
  methods: {
    closeModal() {
      if (!this.model || RescueUnsavedEditsService.okToLeave(this.model)) {
        if (this.close) { return this.close(); } else { return EventBus.$emit('closeModal'); }
      }
    }
  }
};

</script>

<template lang="pug">
v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='closeModal')
  common-icon(name="mdi-close")
</template>
