<script lang="js">
export default {
  props: {
    poll: Object,
    stance: Object,
    prompt: String
  },
  computed: {
    label() {
      if (this.poll.config().has_options) {
        return 'poll_common.reason';
      } else {
        return 'poll_common.response';
      }
    },

    maxLength() {
      if (this.poll.limitReasonLength) {
        return 500;
      } else {
        return undefined;
      }
    }
  }
}
</script>

<template>

<div class="poll-common-stance-reason">
  <lmo-textarea class="poll-common-vote-form__reason" :focus-id="'poll-'+poll.id" v-if="poll.stanceReasonRequired != 'disabled'" :model="stance" field="reason" :label="$t(label)" :placeholder="prompt || poll.reasonPrompt || $t('poll_common.reason_placeholder')" :max-length="maxLength"></lmo-textarea>
  <validation-errors :subject="stance" field="reason"></validation-errors>
</div>
</template>
