<script setup>
import Records from '@/shared/services/records';
import { computed } from 'vue';
import { I18n } from '@/i18n';

const { poll, stance, selectedOptionId } = defineProps({ poll: Object, stance: Object, selectedOptionId: Number });

const label = computed(() => poll.config().has_options ? 'poll_common.reason' : 'poll_common.response');
const maxLength = computed(() => poll.limitReasonLength ? 500 : undefined);

const reasonPrompt = computed(() => {
  if (poll.config().per_option_reason_prompt && selectedOptionId) {
    const pollOption = Records.pollOptions.find(selectedOptionId)
    return poll.translationId ? pollOption.translation().fields.prompt : pollOption.prompt
  }

  if (poll.reasonPrompt) {
    return poll.translationId ? poll.translation().fields['reasonPrompt'] : poll.reasonPrompt
  }

  return I18n.global.t('poll_common.reason_placeholder')
});

</script>

<template lang="pug">
.poll-common-stance-reason
  lmo-textarea.poll-common-vote-form__reason(
    :focus-id="'poll-'+poll.id"
    v-if="poll.stanceReasonRequired != 'disabled'"
    :model='stance'
    field="reason"
    :label="$t(label)"
    :placeholder="reasonPrompt"
    :max-length='maxLength'
  )
  validation-errors(:subject="stance" field="reason")

</template>
