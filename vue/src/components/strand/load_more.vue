<script lang="js">
import EventBus from '@/shared/services/event_bus';
import { mdiArrowExpandVertical } from '@mdi/js';

export default {
  props: {
    direction: String,
    obj: Object,
    loader: Object
  },

  data() {
    return {
      mdiArrowExpandVertical,
      loading: false
    };
  },

  computed: {
    label() {
      switch (this.direction) {
        case 'before':
          return {path: 'common.action.count_more', args: {count: this.obj.missingEarlierCount}};
        case 'after':
          return {path: 'common.action.count_more', args: {count: this.obj.missingAfterCount}};
        case 'children':
          return {path: 'common.action.count_more', args: {count: this.obj.missingChildCount}};
      }
    },
  },
  methods: {
    loadAndScrollTo() {
      const anchorObj = this.direction == "before" ?  this.obj.previousObj : this.obj
      const selector = `.positionKey-${anchorObj.event.positionKey}`
      const offset = document.querySelector(`.positionKey-${anchorObj.event.positionKey}`).getBoundingClientRect().top
      EventBus.$emit('setAnchor', selector, offset);
      this.load();
    },

    load() {
      const event = this.obj.event;
      this.loading = true;
      switch (this.direction) {
        case 'before':
          this.loader.addLoadArgsRule({
            position_key_lt: event.positionKey,
            position_key_sw: event.positionKeyParent(),
            position_key_gte: event.depth > 1 ? event.positionKeyMinus(this.obj.missingEarlierCount) : undefined,
            order_by: 'position_key',
            order_desc: 1,
          });
          break;
        case 'after':
          this.loader.addLoadArgsRule({
            position_key_sw: event.positionKeyParent(),
            position_key_gte: event.nextSiblingPositionKey(),
            order_by: 'position_key'
          })
          break;
        case 'children':
          this.loader.addLoadArgsRule({
            position_key_sw: event.positionKey,
            position_key_gt: event.positionKey,
            order_by: 'position_key'
          })
          break;
      }
      this.loader.fetch().finally(() => {
        this.loading = false;
      });
    }
  }
};
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
