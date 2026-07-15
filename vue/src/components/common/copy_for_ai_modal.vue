<script setup lang="js">
import Flash from '@/shared/services/flash';
import { ref, onMounted } from 'vue';

const { topic, close } = defineProps({ topic: Object, close: Function });
const markdown = ref('');
const loading = ref(true);
const facilitationPrompt = 'https://www.loomio.com/skills/loomio-facilitator/SKILL.md';

onMounted(async () => {
  const response = await fetch(`/api/v1/topics/${topic.id}/markdown`);
  markdown.value = (await response.json()).markdown;
  loading.value = false;
});

async function copyPromptAndThread() {
  await navigator.clipboard.writeText(`${facilitationPrompt}\n\n${markdown.value}`);
  Flash.success('common.copied');
}

async function copyThread() {
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
  v-card-text.pb-2
    p.text-body-2(v-t="'action_dock.copy_for_ai_description'")
  v-card-actions.d-flex.flex-column.align-stretch.ga-2
    v-btn(color="primary" variant="elevated" :disabled="loading" :loading="loading" @click="copyPromptAndThread")
      span(v-t="'action_dock.copy_prompt_and_thread'")
    v-btn(color="primary" variant="tonal" @click="copyPrompt")
      span(v-t="'action_dock.copy_prompt'")
    v-btn(color="primary" variant="tonal" :disabled="loading" @click="copyThread")
      span(v-t="'action_dock.copy_thread'")
</template>
