<script setup lang="js">
import Flash from '@/shared/services/flash';
import { ref, onMounted } from 'vue';

const { topic, close } = defineProps({ topic: Object, close: Function });
const markdown = ref('');
const loading = ref(true);
const facilitationPrompt = `Read these Loomio facilitation guides before analysing the conversation:
- https://www.loomio.com/blog/2015/09/18/9-ways-to-use-a-loomio-proposal-to-turn-a-conversation-into-action/
- https://www.loomio.com/skills/loomio-facilitator/SKILL.md

Then read the Loomio thread transcript I provide. Explain: (1) the decision or purpose of the thread, (2) what seems agreed, (3) unanswered questions and concerns or objections that need attention, (4) whose participation may still be needed, and (5) the most suitable way to move the conversation forward. Offer a draft comment, poll, or outcome only for my review. Do not claim consensus from a majority vote, infer identities in an anonymous poll, or take any action on Loomio.`;

onMounted(async () => {
  const response = await fetch(`/api/v1/topics/${topic.id}/markdown`);
  markdown.value = (await response.json()).markdown;
  loading.value = false;
});

async function copy() {
  await navigator.clipboard.writeText(markdown.value);
  Flash.success('action_dock.thread_copied_for_ai');
}

async function copyPrompt() {
  await navigator.clipboard.writeText(facilitationPrompt);
  Flash.success('action_dock.facilitation_prompt_copied');
}
</script>

<template lang="pug">
v-card(:title="$t('action_dock.copy_thread_for_ai')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    p.text-body-2(v-t="'action_dock.copy_thread_for_ai_help'")
    v-textarea(:model-value="facilitationPrompt" readonly auto-grow)
    v-btn.mb-4(variant="outlined" @click="copyPrompt")
      span(v-t="'action_dock.copy_facilitation_prompt'")
    v-progress-linear(v-if="loading" indeterminate)
    v-textarea(v-else :model-value="markdown" readonly auto-grow)
  v-card-actions
    v-spacer
    v-btn(color="primary" :disabled="loading" @click="copy")
      span(v-t="'common.copy'")
</template>
