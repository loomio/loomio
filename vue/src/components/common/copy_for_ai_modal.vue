<script setup lang="js">
import Flash from '@/shared/services/flash';
import { ref, onMounted } from 'vue';

const { topic } = defineProps({ topic: Object, close: Function });
const markdown = ref('');
const loading = ref(true);

async function loadThread() {
  const response = await fetch(`/api/v1/topics/${topic.id}/markdown`);
  if (!response.ok) throw new Error('Could not load thread Markdown');
  markdown.value = (await response.json()).markdown;
}

onMounted(async () => {
  try {
    await loadThread();
  } catch (error) {
    console.error(error);
    Flash.error('common.something_went_wrong');
  } finally {
    loading.value = false;
  }
});

async function copyThread() {
  await navigator.clipboard.writeText(markdown.value);
  Flash.success('action_dock.thread_markdown_copied');
}
</script>

<template lang="pug">
v-card(:title="$t('action_dock.copy_markdown')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.pb-2
    p.text-body-2(v-t="'action_dock.copy_markdown_description'")
  v-card-actions.justify-center
    v-btn(color="primary" variant="elevated" :disabled="loading || !markdown" :loading="loading" @click="copyThread")
      span(v-t="'action_dock.copy_thread'")
</template>
