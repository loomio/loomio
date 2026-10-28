<script setup>
import { computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import TagsDisplay from './display.vue';

const { topic } = defineProps({topic: {type: Object, required: true}});
const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const selectedTag = computed(() => route.query.tag);

function tagRoute(tag) {
  const query = {...route.query};
  if (tag === selectedTag.value) { delete query.tag; }
  else { query.tag = tag; }
  return {path: route.path, query};
}
</script>

<template lang="pug">
v-list.thread-tags(v-if="topic.hasTaggedReplies" nav slim density="compact" :lines="false")
  v-list-subheader {{ t('loomio_tags.tags') }}
  tags-display.thread-tags__tags.d-flex.flex-wrap.px-2.text-medium-emphasis(:tags="topic.tags" :group="topic.group()" :selected="selectedTag || ''" :tag-route="tagRoute")
  v-btn.thread-tags__clear.ml-2(v-if="selectedTag" size="small" variant="text" @click="router.push(tagRoute(selectedTag))") {{ t('common.action.clear') }}
</template>

<style scoped>
.thread-tags__tags {
  row-gap: 4px;
  padding-bottom: 4px;
}
</style>
