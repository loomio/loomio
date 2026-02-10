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
    this.poll.openingAt = null;
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
    return {
      isDisabled: false,
      votingOpensImmediately: true
    };
  }
}
</script>

<template lang="pug">
v-card.poll-common-reopen-modal(:title="$t('poll_common_reopen_form.title', {poll_type: poll.translatedPollType()})")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.poll-common-reopen-form
    p.text-medium-emphasis(v-t="{path: 'poll_common_reopen_form.helptext', args: {poll_type: poll.translatedPollType()}}")
    v-checkbox.mt-2(
      hide-details
      v-model="votingOpensImmediately"
      :label="$t('poll_common_opening_at_field.voting_opens_immediately')"
      @update:modelValue="val => { if (val) poll.openingAt = null }"
    )
    poll-common-opening-at-field.pb-4(:poll="poll" :disabled="votingOpensImmediately")
    poll-common-closing-at-field(:poll='poll' :min-date="poll.openingAt")
  v-card-actions
    v-spacer
    v-btn.poll-common-reopen-form__submit(variant="elevated" color="primary" @click='submit' :loading="poll.processing")
      span(v-t="'common.action.reopen'")
</template>
