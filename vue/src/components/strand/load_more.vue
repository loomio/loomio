<script setup>
import EventBus from '@/shared/services/event_bus';
import { mdiArrowExpandVertical } from '@mdi/js';
import Records from '@/shared/services/records';
import { ref, computed } from 'vue';
import { last } from 'lodash-es';

const { direction, collection, parentCollection, index, loader } = defineProps({
  direction: String,
  collection: Object,
  parentCollection: Object,
  index: Number,
  loader: Object
});

// const loadAndScrollTo = () => {
//   const selector = `.positionKey-${collection[index].event.parent().positionKey}`
//   const offset = document.querySelector(selector).getBoundingClientRect().top
//   EventBus.$emit('setAnchor', selector, offset);
//   load();
// }

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

const lastChild = (obj) => {
  if (obj.children.length == 0) {
    return obj;
  } else {
    return lastChild(last(obj.children));
  }
}

const params = () => {
  const event = collection[index].event;
  switch (direction) {
    case 'before':
      return {
        position_key_gt: (collection[index - 1] && lastChild(collection[index - 1])|| { event: {} }) .event.positionKey,
        position_key_sw: positionKeyParent(),
        position_key_lt: event.positionKey,
        order_by: 'position_key',
        order_desc: 1,
      };
    case 'after':
      return {
        position_key_sw: positionKeyParent(),
        position_key_gte: nextSiblingPositionKey(),
        order_by: 'position_key'
      }
    case 'children':
      return {
        position_key_sw: event.positionKey,
        position_key_gt: event.positionKey,
        order_by: 'position_key'
      }
  }
};

const loading = ref(false);
const load = () => {
  loading.value = true;
  loader.addLoadArgsRule(params());
  loader.fetch().finally(() => loading.value = false);
};

const count = ref(null);
Records.fetch({
  path: 'events/count',
  params: Object.assign({}, { discussion_id: loader.discussion.id }, params())
}).then((val) => count.value = val );

</script>

<template lang="pug">
.strand-item__load-more
  v-btn.action-button(block variant="tonal" color="info" @click="load" :loading="loading" size="x-large")
    v-icon.mr-2(:icon="mdiArrowExpandVertical")
    span {{direction }}
    span(v-t="{path: 'common.action.count_more', args: {count: count}}")
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
