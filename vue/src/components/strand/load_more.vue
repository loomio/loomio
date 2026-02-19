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
    const selector = `.positionKey-${collection[index].event.positionKey}`
    const offset = document.querySelector(selector).getBoundingClientRect().top
    EventBus.$emit('setAnchor', selector, offset);
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
  const event = collection[index].event;
  let strs = event.positionKey.split("-")
  let num = event.position + 1
  strs[strs.length - 1] = "0".repeat(5 - String(num).length).concat(num)
  return strs.join("-")
}

const positionKeyParent = () => {
  return collection[index].event.positionKey.split('-').slice(0, -1).join('-');
}

const params = () => {
  const event = collection[index].event;
  switch (direction) {
    case 'before':
      return pickBy({
        position_key_gte: (collection[index - 1] && positionKeyPlusOne(collection[index - 1].event.positionKey)),
        position_key_gt: positionKeyParent(),
        position_key_lt: event.positionKey,
        depth_lte: event.depth,
        order_by: 'position_key',
        order_desc: 1,
      });
    case 'after':
      return pickBy({
        position_key_sw: positionKeyParent(),
        position_key_gte: positionKeyPlusOne(collection[index].event.positionKey),
        position_key_lt: collection[index + 1] ? collection[index + 1].event.positionKey : null,
        depth_lte: collection[index].event.depth + 1,
        order_by: 'position_key'
      });
    case 'children':
      return pickBy({
        position_key_sw: event.positionKey,
        position_key_gt: event.positionKey,
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
    path: 'events/count',
    params: Object.assign({}, { topic_id: loader.topic.id }, params())
  }).then((val) => count.value = val );
}, { immediate: true })

const size = () => {
  switch (collection[index].event.depth) {
    case 1: return 'x-large';
    case 2: return 'default';
    case 3: return 'default';
  }
}
</script>

<template lang="pug">
.strand-item__load-more
  v-btn.text-none(block variant="tonal" color="primary" @click="loadAndScrollTo" :loading="loading" :size="size()")
    v-icon.mr-2(v-if="direction === 'before'" :icon="mdiArrowExpandUp")
    v-icon.mr-2(v-if="direction === 'after'" :icon="mdiArrowExpandDown")
    v-icon.mr-2(v-if="direction === 'children'" :icon="mdiArrowExpandDown")
    span(v-t="{path: 'common.action.count_more', args: {count: count}}")
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
