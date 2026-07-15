<script setup lang="js">
import Flash from '@/shared/services/flash';
import { ref, onMounted } from 'vue';

const { topic, close } = defineProps({ topic: Object, close: Function });
const markdown = ref('');
const skillMarkdown = ref('');
const loading = ref(true);
const skillPath = '/skills/loomio-facilitator/SKILL.md';
const skillUrl = new URL(skillPath, window.location.origin).href;

async function loadThread() {
  const response = await fetch(`/api/v1/topics/${topic.id}/markdown`);
  if (!response.ok) throw new Error('Could not load thread Markdown');
  markdown.value = (await response.json()).markdown;
}

async function loadSkill() {
  const response = await fetch(skillPath);
  if (!response.ok) throw new Error('Could not load Loomio facilitator skill');
  skillMarkdown.value = await response.text();
}

onMounted(async () => {
  const results = await Promise.allSettled([loadThread(), loadSkill()]);
  const errors = results.filter(({ status }) => status === 'rejected');

  if (errors.length) {
    errors.forEach(({ reason }) => console.error(reason));
    Flash.error('common.something_went_wrong');
  }

  loading.value = false;
});

function skillWithSource() {
  return `${skillMarkdown.value.trim()}\n\nSkill source: ${skillUrl}`;
}

async function copySkillAndThread() {
  const content = `${skillWithSource()}\n\n---\n\n# Loomio thread transcript\n\n${markdown.value}`;
  await navigator.clipboard.writeText(content);
  Flash.success('common.copied');
}

async function copyThread() {
  await navigator.clipboard.writeText(markdown.value);
  Flash.success('action_dock.thread_copied_for_ai');
}

async function copySkill() {
  await navigator.clipboard.writeText(skillWithSource());
  Flash.success('common.copied');
}
</script>

<template lang="pug">
v-card(:title="$t('action_dock.copy_thread_for_ai')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.pb-2
    p.text-body-2(v-t="'action_dock.copy_for_ai_skill_description'")
    v-alert.mt-4(type="info" variant="tonal" density="compact")
      div(v-t="'action_dock.share_ai_skill'")
      router-link(to="/contact" @click="close" v-t="'action_dock.share_ai_skill_contact'")
  v-card-actions.d-flex.flex-column.align-stretch.ga-2
    v-btn(color="primary" variant="elevated" :disabled="loading || !skillMarkdown || !markdown" :loading="loading" @click="copySkillAndThread")
      span(v-t="'action_dock.copy_skill_and_thread'")
    v-btn(color="primary" variant="tonal" :disabled="loading || !skillMarkdown" @click="copySkill")
      span(v-t="'action_dock.copy_skill'")
    v-btn(color="primary" variant="tonal" :disabled="loading || !markdown" @click="copyThread")
      span(v-t="'action_dock.copy_thread'")
</template>
