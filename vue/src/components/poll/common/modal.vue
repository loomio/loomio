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
<template>

<v-card class="poll-common-modal pb-2" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()">
  <submit-overlay :value="poll.processing"></submit-overlay>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="title_key"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button :model="poll"></dismiss-modal-button>
  </v-card-title>
  <div class="px-4">
    <poll-common-form :poll="poll"></poll-common-form>
  </div>
</v-card>
</template>
