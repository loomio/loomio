<script lang="js">
export default {
  props: {
    direction: String,
    obj: Object,
    loader: Object,
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
    intersectHandler(isVisible){
      if (!isVisible) { return }
      switch (this.direction) {
        case 'before':
          return this.loader.loadBefore(this.obj);
        case 'after':
          return this.loader.loadAfter(this.obj)
        case 'children':
          return this.loader.loadChildren(this.obj.event);
      }
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
  v-btn.action-button(block variant="tonal" @click="load" :loading="loading")
    span(v-t="label")
</template>

<style lang="sass">
.strand-item__load-more
  width: 100%
  padding: 8px 0
</style>
