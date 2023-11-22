<script lang="js">
import Records from '@/shared/services/records';
import Flash   from '@/shared/services/flash';
import { addDays } from 'date-fns';

export default {
  props: {
    poll: Object,
    close: Function
  },

  created() {
    this.poll.closingAt = addDays(new Date, 7);
  },

  methods: {
    submit() {
      this.poll.reopen().then(() => {
        this.poll.processing = false;
        Flash.success("poll_common_reopen_form.success", {poll_type: this.poll.translatedPollType()});
        this.close();
      });
    }
  },
  data() {
    return {isDisabled: false};
  }
}
</script>

<template>

<v-card class="poll-common-reopen-modal">
  <submit-overlay :value="poll.processing"></submit-overlay>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="{path: 'poll_common_reopen_form.title', args: {poll_type: poll.translatedPollType()}}"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text class="poll-common-reopen-form"><span class="text--secondary" v-t="{path: 'poll_common_reopen_form.helptext', args: {poll_type: poll.translatedPollType()}}"></span>
    <poll-common-closing-at-field :poll="poll"></poll-common-closing-at-field>
  </v-card-text>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn class="poll-common-reopen-form__submit" color="primary" @click="submit" :loading="poll.processing"><span v-t="'common.action.reopen'"></span></v-btn>
  </v-card-actions>
</v-card>
</template>
