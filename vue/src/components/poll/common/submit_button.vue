<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { mdiReply, mdiVoteOutline } from '@mdi/js';

const { stance, guidance = '', loading = false } = defineProps({
  stance: {type: Object, required: true},
  guidance: String,
  loading: Boolean
});
const { t } = useI18n();
const poll = computed(() => stance.poll());
const label = computed(() => {
  if (guidance) return guidance;
  if (poll.value.config().has_options) {
    return t(stance.castAt ? 'poll_common.update_vote' : 'poll_common.submit_vote');
  }
  return t(stance.castAt ? 'poll_common.update_response' : 'poll_common.submit_response');
});
</script>

<template>
  <v-btn
    class="poll-common-vote-form__submit"
    type="submit"
    :disabled="!!guidance || !poll.isVotable()"
    :loading="loading"
    :prepend-icon="poll.config().has_options ? mdiVoteOutline : mdiReply"
    color="primary"
    variant="elevated"
    block
  >{{ label }}</v-btn>
</template>
