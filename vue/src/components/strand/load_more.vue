<script lang="js">
import ScrollService from '@/shared/services/scroll_service';
import { mdiArrowExpandVertical } from '@mdi/js';

export default {
  props: {
    direction: String,
    obj: Object,
    loader: Object,
  },

  data() {
    return {
      mdiArrowExpandVertical
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
    loading() {
      return this.loader.loading == this.direction + this.obj.event.id;
    }
  },
  methods: {
    loadAndScrollTo() {
      const selector = `.positionKey-${this.obj.event.positionKey}`
      const offset = document.querySelector(`.positionKey-${this.obj.event.positionKey}`).getBoundingClientRect().top
      this.load().finally(() => {
        ScrollService.jumpTo(selector, offset);
      });
    },

    load() {
      switch (this.direction) {
        case 'before':
          return this.loader.loadBefore(this.obj.event);
        case 'after':
          return this.loader.loadAfter(this.obj.event);
        case 'children':
          return this.loader.loadChildren(this.obj.event);
      }
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
    //space
    //span {{direction}}
    //span {{this.obj.event.positionKey}}
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
