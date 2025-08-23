<script setup>
import EventBus from '@/shared/services/event_bus';
import { mdiArrowExpandVertical } from '@mdi/js';
import { ref, computed } from 'vue';

const { direction, obj, loader } = defineProps({
  direction: String,
  obj: Object,
  loader: Object
});

const loading = ref(false);
// const count = ref(null);

const label = computed(() => {
  switch (direction) {
    case 'before':
      return {path: 'common.action.count_more', args: {count: obj.missingEarlierCount}};
    case 'after':
      return {path: 'common.action.count_more', args: {count: obj.missingAfterCount}};
    case 'children':
      return {path: 'common.action.count_more', args: {count: obj.missingChildCount}};
  }
});

const loadAndScrollTo = () => {
  const anchorObj = direction == "before" ?  obj.previousObj : obj
  const selector = `.positionKey-${anchorObj.event.positionKey}`
  const offset = document.querySelector(`.positionKey-${anchorObj.event.positionKey}`).getBoundingClientRect().top
  EventBus.$emit('setAnchor', selector, offset);
  load();
}

const scopeArgs = () => {
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

const load = () => {
  const event = obj.event;
  loading.value = true;
  loader.addLoadArgsRule(scopeArgs());
  loader.fetch().finally(() => loading.value = false);
};

// const fetchCount = () => {
//   Records.fetch({
//     path: 'events/count',
//     params: this.scopeArgs()
//   }).then((count) => {
//     this.count = count;
//   });
// };

</script>

<template lang="pug">
//.strand-item__load-more(v-intersect.once="{handler: intersectHandler}")
.strand-item__load-more
  v-btn.action-button(block variant="outlined" color="info" @click="loadAndScrollTo" :loading="loading" size="x-large")
    v-icon.mr-2(:icon="mdiArrowExpandVertical")
    span(v-t="label")
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
