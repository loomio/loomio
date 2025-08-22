<script lang="js">
import EventBus from '@/shared/services/event_bus';
import { mdiArrowExpandVertical } from '@mdi/js';

export default {
  props: {
    direction: String,
    obj: Object,
    loader: Object,
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
      const selector = `.positionKey-${this.obj.event.positionKey}`
      const offset = document.querySelector(`.positionKey-${this.obj.event.positionKey}`).getBoundingClientRect().top
      EventBus.$emit('setFocus', selector, offset);
      this.load();
    },

    load() {
      const event = this.obj.event;
      this.loading = true;
      switch (this.direction) {
        case 'before':
          if (event.depth > 1) {
            const prefix = event.positionKey.split('-').slice(0, event.depth - 1).join('-');
            this.loader.addLoadBeforePrefixedRule(this.obj.event, prefix);
          } else {
            this.loader.addLoadBeforeRule(this.obj.event);
          }
          break;
        case 'after':
          if (event.depth > 1) {
            const prefix = event.positionKey.split('-').slice(0, event.depth - 1).join('-');
            this.loader.addLoadAfterPrefixedRule(this.obj.event, prefix);
          } else {
            this.loader.addLoadAfterRule(this.obj.event);
          }
          break;
        case 'children':
          const prefix = event.positionKey.split('-').slice(0, event.depth - 1).join('-');
          this.loader.addLoadChildrenRule(event, prefix);
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
    space
    span depth: {{this.obj.event.depth}}
    span {{direction}}
    span {{this.obj.event.positionKey}}
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
