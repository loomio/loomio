<script lang="js">
import EventBus from '@/shared/services/event_bus';

export default {
  props: {
    close: Function,
  },
  methods: {
    closeModal() {
      if (this.close) { return this.close(); } else { return EventBus.$emit('closeModal'); }
    }
  }
};

</script>

<template lang="pug">
v-btn.dismiss-modal-button(icon variant="text" :aria-label="$t('common.action.cancel')" @click='closeModal')
  common-icon(name="mdi-close")
</template>
