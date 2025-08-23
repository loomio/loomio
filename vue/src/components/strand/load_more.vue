<script setup>
import EventBus from '@/shared/services/event_bus';
import { mdiArrowExpandVertical } from '@mdi/js';
import Records from '@/shared/services/records';
import { ref, computed } from 'vue';
const { direction, obj, loader } = defineProps({
  direction: String,
  obj: Object,
  loader: Object
});

const positionCount = computed(() => {
  switch (direction) {
    case 'before':
      return obj.missingEarlierCount;
    case 'after':
      return obj.missingAfterCount;
    case 'children':
      return obj.missingChildCount;
  }
});

const loadAndScrollTo = () => {
  const anchorObj = direction == "before" ?  obj.previousObj : obj
  const selector = `.positionKey-${anchorObj.event.positionKey}`
  const offset = document.querySelector(`.positionKey-${anchorObj.event.positionKey}`).getBoundingClientRect().top
  EventBus.$emit('setAnchor', selector, offset);
  load();
}

const params = () => {
  const event = obj.event;
  switch (direction) {
    case 'before':
      return {
        position_key_lt: event.positionKey,
        position_key_sw: event.positionKeyParent(),
        position_key_gte: event.depth > 1 ? event.positionKeyMinus(obj.missingEarlierCount) : undefined,
        order_by: 'position_key',
        order_desc: 1,
      };
    case 'after':
      return {
        position_key_sw: event.positionKeyParent(),
        position_key_gte: event.nextSiblingPositionKey(),
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
  const event = obj.event;
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
  v-btn.action-button(block variant="tonal" color="info" @click="loadAndScrollTo" :loading="loading" size="x-large")
    v-icon.mr-2(:icon="mdiArrowExpandVertical")
    span(v-t="{path: 'common.action.count_more', args: {count: count}}")
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
