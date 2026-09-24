<script setup lang="js">
import Flash from '@/shared/services/flash';
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { downloadFile } from '@/shared/helpers/download_file';

const { topic } = defineProps({ topic: Object, close: Function });
const markdown = ref('');
const loading = ref(true);
const copying = ref(false);
const { t } = useI18n();

async function loadThread() {
  const response = await fetch(`/api/v1/topics/${topic.id}/markdown`);
  if (!response.ok) throw new Error('Could not load thread Markdown');
  return (await response.json()).markdown;
}

onMounted(async () => {
  try {
    markdown.value = await loadThread();
  } catch (error) {
    console.error(error);
    Flash.error('common.something_went_wrong');
  } finally {
    loading.value = false;
  }
});

async function copyThread() {
  try {
    copying.value = true;
    await navigator.clipboard.writeText(markdown.value);
    Flash.success('action_dock.thread_markdown_copied');
  } catch (error) {
    console.error(error);
    Flash.error('common.something_went_wrong');
  } finally {
    copying.value = false;
  }
}

// Strip only characters that filesystems reject, so titles in any script keep
// their words in the filename.
function downloadFilename() {
  const name = topic.title.replace(/[\/\\:*?"<>|\u0000-\u001f]+/g, '').trim();
  return `${name || 'thread'}.md`;
}

function downloadThread() {
  downloadFile(markdown.value, 'text/markdown', downloadFilename());
}
</script>

<template lang="pug">
v-card(:title="t('action_dock.copy_markdown')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.pb-2
    p.text-body-2 {{ t('action_dock.copy_markdown_description') }}
  v-card-actions.justify-center
    v-btn(color="primary" variant="elevated" :disabled="loading || !markdown" :loading="loading || copying" @click="copyThread")
      span {{ t('action_dock.copy_markdown') }}
    v-btn(color="primary" variant="elevated" :disabled="loading || !markdown" :loading="loading" @click="downloadThread")
      span {{ t('action_dock.download_markdown') }}
</template>
