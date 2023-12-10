<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash  from '@/shared/services/flash';

export default {
  props: {
    poll: Object
  },

  computed: {
    title_key() {
      const mode = this.poll.isNew() ? 'start': 'edit';
      return 'poll_' + this.poll.pollType + '_form.'+mode+'_header';
    },

    isEditing() {
      return this.poll.closingAt && !this.poll.isNew();
    }
  }
};

</script>
<template lang="pug">
v-card.poll-common-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()").pb-2
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.text-h5(tabindex="-1" v-t="title_key")
    v-spacer
    dismiss-modal-button(:model='poll')
  div.px-4
    poll-common-form(:poll='poll')
</template>
