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

    normalizedTags() {
      return this.tags.map((item, i) => {
        if (item && typeof item === 'object' && item.id) return item;
        const name = (typeof item === 'string') ? item : (item && item.name);
        const model = this.group.tags().find(t => t.name === name);
        return model || { name };
      });
    }
  }
};

</script>
<template lang="pug">
span.tags-display
  v-chip.mr-1(
    v-for="tag in normalizedTags"
    :key="tag.id || tag.name"
    :outlined="tag.name != selected"
    :size="size"
    :color="tag.color"
    :to="'/g/'+groupKey+'/tags/'+encodeURIComponent(tag.name)"
    :class="{'mb-1': showCounts}"
  )
    plain-text.text-on-surface(:model="tag" field="name")
    span(v-if="showCounts")
      space
      span {{tag.taggingsCount}}
    span(v-if="showOrgCounts")
      space
      span {{tag.orgTaggingsCount}}
</template>
