<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash  from '@/shared/services/flash';
import { useI18n } from 'vue-i18n';

export default {
  setup() { return { t: useI18n().t }; },
  props: {
    poll: Object
  },

  computed: {
    title_key() {
      return this.poll.isNew() ? 'action_dock.new_poll_type' : 'action_dock.edit_poll_type';
    },

    isEditing() {
      return this.poll.closingAt && !this.poll.isNew();
    }
  }
};

</script>
<template lang="pug">
v-card.poll-common-modal(v-submit-on-mod-enter="submit").pb-2
  v-card-title
    h1.text-headline-small(tabindex="-1") {{ t(title_key, {pollType: poll.translatedPollType()}) }}
    v-spacer
    dismiss-modal-button(:model='poll')
  div.px-4
    poll-common-form(:poll='poll')
</template>
