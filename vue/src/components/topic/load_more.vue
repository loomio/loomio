<script setup>
import EventBus from '@/shared/services/event_bus';
import { mdiArrowExpandUp, mdiArrowExpandDown } from '@mdi/js';
import Records from '@/shared/services/records';
import { ref, watch } from 'vue';
import { pickBy } from 'lodash-es';

const { direction, collection, parentCollection, index, loader } = defineProps({
  direction: String,
  collection: Object,
  parentCollection: Object,
  index: Number,
  loader: Object
});

const loadAndScrollTo = () => {
  if (direction == 'before') {
    // Before loading items above the current position, record the top visible item's
    // selector and its current screen offset. page.vue listens for this and sets
    // anchorSelector/anchorOffset so that after the new items are inserted above,
    // ScrollService can restore the viewport to the same visual position (preventing
    // the page from jumping).
    const selector = `.positionKey-${collection[index].topic_item.positionKey}`
    const el = document.querySelector(selector);
    if (el) {
      EventBus.$emit('setAnchor', selector, el.getBoundingClientRect().top);
    }
  }
  load();
}

const positionKeyPlusOne = (positionKey) => {
  let strs = positionKey.split("-")
  let num = parseInt(strs[strs.length - 1]) + 1
  strs[strs.length - 1] = "0".repeat(5 - String(num).length).concat(num)
  return strs.join("-")
}

const nextSiblingPositionKey = () => {
  // skipping any child positions
  const topic_item = collection[index].topic_item;
  let strs = topic_item.positionKey.split("-")
  let num = topic_item.position + 1
  strs[strs.length - 1] = "0".repeat(5 - String(num).length).concat(num)
  return strs.join("-")
}

const positionKeyParent = () => {
  return collection[index].topic_item.positionKey.split('-').slice(0, -1).join('-');
}

const params = () => {
  const topic_item = collection[index].topic_item;
  switch (direction) {
    case 'before':
      return pickBy({
        position_key_gte: (collection[index - 1] && positionKeyPlusOne(collection[index - 1].topic_item.positionKey)),
        position_key_gt: positionKeyParent(),
        position_key_lt: topic_item.positionKey,
        depth_lte: topic_item.depth,
        order_by: 'position_key',
        order_desc: 1,
      });
    case 'after':
      return pickBy({
        position_key_sw: positionKeyParent(),
        position_key_gte: positionKeyPlusOne(collection[index].topic_item.positionKey),
        position_key_lt: collection[index + 1] ? collection[index + 1].topic_item.positionKey : null,
        depth_lte: collection[index].topic_item.depth + 1,
        order_by: 'position_key'
      });
    case 'children':
      return pickBy({
        position_key_sw: topic_item.positionKey,
        position_key_gt: topic_item.positionKey,
        order_by: 'position_key'
      });
  }
};

const loading = ref(false);
const load = () => {
  loading.value = true;
  loader.addLoadArgsRule(params());
  loader.fetch().finally(() => loading.value = false);
};

const count = ref("~");
watch(() => collection.length, () => {
  Records.fetch({
    path: 'topic_items/count',
    params: Object.assign({}, { topic_id: loader.topic.id }, params())
  }).then((val) => count.value = val );
}, { immediate: true })

const size = () => {
  switch (collection[index].topic_item.depth) {
    case 1: return 'x-large';
    case 2: return 'default';
    case 3: return 'default';
  }
}
</script>

<template lang="pug">
.topic-item__load-more
  v-btn.text-none(block variant="tonal" color="primary" @click="loadAndScrollTo" :loading="loading" :size="size()")
    v-icon.mr-2(v-if="direction === 'before'" :icon="mdiArrowExpandUp")
    v-icon.mr-2(v-if="direction === 'after'" :icon="mdiArrowExpandDown")
    v-icon.mr-2(v-if="direction === 'children'" :icon="mdiArrowExpandDown")
    span(v-t="{path: 'common.action.count_more', args: {count: count}}")
</template>

<style>
.topic-item__load-more {
  width: 100%;
  padding: 8px 0;
}
</style>
