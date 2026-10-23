<script setup>
import { ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useWatchRecords } from '@/composables/useWatchRecords';
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import TopicList from './list.vue';

const { topic, loader, tag } = defineProps({topic: Object, loader: Object, tag: String});
const { t } = useI18n();
const { watchRecords } = useWatchRecords();
const matchedIds = ref([]);
const offset = ref(0);
const loading = ref(false);
const hasMore = ref(false);
const revision = ref(0);
const limit = 25;
let request = 0;

// The server pages matches; serialized parent records provide context without
// bringing unrelated siblings into the filtered view or consuming page slots.
const collection = computed(() => {
  revision.value;
  const items = new Map();
  for (const id of matchedIds.value) {
    let item = Records.topicItems.find(id);
    if (!item.tags.includes(tag)) { continue; }
    if (item.replyParent()) { items.set(item.replyParent().id, item.replyParent()); }
    while (item && !items.has(item.id)) {
      items.set(item.id, item);
      item = item.parent();
    }
  }
  // Include ancestry for actual reply parents at the display depth limit too.
  for (const item of items.values()) {
    for (let parent = item.parent(); parent && !items.has(parent.id); parent = parent.parent()) {
      items.set(parent.id, parent);
    }
  }
  const children = new Map();
  for (const item of [...items.values()].sort((a, b) => a.positionKey.localeCompare(b.positionKey))) {
    const key = items.has(item.parentId) ? item.parentId : null;
    if (!children.has(key)) { children.set(key, []); }
    children.get(key).push(item);
  }
  const nest = parentId => (children.get(parentId) || []).map(item => ({
    topic_item: item, itemable: item.model(), children: nest(item.id), isUnread: false
  }));
  return nest(null);
});

async function fetchPage(reset = false) {
  const currentRequest = ++request;
  if (reset) { matchedIds.value = []; offset.value = 0; }
  loading.value = true;
  try {
    const data = await Records.fetch({path: 'topic_items/tagged', params: {topic_id: topic.id, tag, limit, offset: offset.value}});
    if (currentRequest !== request) { return; }
    const ids = data.topic_items.map(item => item.id);
    matchedIds.value = [...new Set([...matchedIds.value, ...ids])];
    offset.value += ids.length;
    hasMore.value = ids.length === limit;
  } catch (error) {
    if (currentRequest === request) { Flash.serverError(error); }
  } finally {
    if (currentRequest === request) { loading.value = false; }
  }
}

watch(() => tag, () => fetchPage(true), {immediate: true});
watchRecords({key: 'taggedItems' + topic.id, collections: ['topic_items'], query: () => revision.value++});
</script>

<template lang="pug">
.tagged-items
  topic-list.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="collection" filtered)
  p.pa-4(v-if="!loading && !collection.length") {{ t('common.no_results_found') }}
  .d-flex.justify-center.pa-3
    v-btn(v-if="hasMore" :loading="loading" variant="text" @click="fetchPage()") {{ t('common.action.load_more') }}
    v-progress-circular(v-else-if="loading" indeterminate :size="24")
</template>
