<script lang="js">
import Records from '@/shared/services/records';

export default {
  props: {
    tags: Array,
    group: Object,
    showCounts: Boolean,
    showOrgCounts: Boolean,
    selected: String,
    size: {
      type: String,
      default: 'small'
    },
    selected: String
  },

  computed: {
    groupKey() {
      return this.group.key;
    },

    byName() { 
      const res = {};
      this.group.tags().forEach(t => res[t.name] = t);
      return res;
    },

    tagObjects() {
      return this.tags.map((name, i) => {
        return {
          id: i,
          name,
          color: (this.byName[name] || {}).color,
          taggingsCount: (this.byName[name] || {}).taggingsCount
        };
      });
    }
  }
};

</script>
<template lang="pug">
span.tags-display
  v-chip.mr-1(
    v-for="tag in tagObjects"
    :key="tag.id"
    :outlined="tag.name != selected"
    :size="size"
    :color="tag.color"
    :to="'/g/'+groupKey+'/tags/'+encodeURIComponent(tag.name)"
    :class="{'mb-1': showCounts}"
  )
    span.text-on-surface {{ tag.name }}
    span(v-if="showCounts")
      space
      span {{tag.taggingsCount}}
    span(v-if="showOrgCounts")
      space
      span {{tag.orgTaggingsCount}}
</template>
