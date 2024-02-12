<script lang="js">
import Flash  from '@/shared/services/flash';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus from '@/shared/services/event_bus';

export default {
  props: {
    close: {
      type: Function,
      default() {
        EventBus.$emit('closeModal');
      }
    },
    titlePath: String,
    bodyPath: String,
    args: {
      type: Object,
      default: () => { {} }
    }
  }
}
</script>

<template lang="pug">
v-card.alert-modal
  v-card-title
    h1.text-h5(v-t="{path: titlePath, args: args}")
    v-spacer
    dismiss-modal-button
  v-card-text
    p(v-t="{path: bodyPath, args: args}")
</template>
