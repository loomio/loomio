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
    paths: Object,
    args: Object
  }
}
</script>

<template lang="pug">
v-card.info-modal
  v-card-title
    h1.headline(v-t="{path: paths.title, args: args}" tabindex="-1")
    v-spacer
    dismiss-modal-button
  v-card-text
    p(v-t="{path: paths.body, args: args}")
  v-card-actions
    v-btn(text @click="close()" v-t="'common.action.ok'")
</template>
