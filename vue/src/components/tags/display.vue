<script setup lang="js">
import Records from '@/shared/services/records';
import { computed } from 'vue';

const { tags, group, selected, size, density, tagRoute } = defineProps({
  tags: Array,
  tagRoute: Function,
  group: Object,
  selected: String,
  density: String,
  size: {
    type: String,
    default: 'small'
  }
});

const allTags = computed(() => group ? group.tags() : []);

const groupKey = computed(() => group?.key);

const byName = computed(() => {
  const res = {};
  allTags.value.forEach(t => res[t.name] = t);
  return res;
});

const tagObjects = computed(() => {
  return tags.map((name, i) => {
    return {
      id: i,
      name,
      color: (byName.value[name] || {}).color,
      to: tagRoute ? tagRoute(name) : groupKey.value ? '/g/'+groupKey.value+'/tags/'+encodeURIComponent(name) : null
    };
  }).sort((a, b) => a.name.localeCompare(b.name));
});

function tagDotStyle(tag) {
  return tag.color ? {backgroundColor: tag.color} : {};
}
</script>
<template lang="pug">
span.tags-display
  v-chip.mr-1(
    v-for="tag in tagObjects"
    :key="tag.id || tag.name"
    :size="size"
    :density="density"
    :to="tag.to"
    :variant="selected === tag.name ? 'flat' : 'tonal'"
    :aria-pressed="selected === undefined ? undefined : selected === tag.name"
  )
    .tag-color-dot(:style="tagDotStyle(tag)")
    plain-text(:model="tag" field="name")
</template>

<style>
.tags-display .tag-color-dot {
  border-radius: 50%;
  display: inline-block;
  height: 10px;
  margin-right: 6px;
  width: 10px;
}
</style>
