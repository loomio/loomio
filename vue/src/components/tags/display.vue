<script setup lang="js">
import Records from '@/shared/services/records';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted } from 'vue';

const { tags, group, selected, size } = defineProps({
  tags: Array,
  group: Object,
  selected: String,
  size: {
    type: String,
    default: 'small'
  }
});

const { watchRecords } = useWatchRecords();
const allTags = ref([]);

onMounted(() => {
  allTags.value = group.tags();
  watchRecords({
    collections: ['tags'],
    query: () => { allTags.value = group.tags(); }
  });
});

const groupKey = computed(() => group.key);

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
      to: groupKey.value ? '/g/'+groupKey.value+'/tags/'+encodeURIComponent(name) : null
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
    :to="tag.to"
    variant="tonal"
  )
    .tag-color-dot(:style="tagDotStyle(tag)")
    plain-text(:model="tag" field="name")
</template>

<style lang="sass">
.tags-display .tag-color-dot
  border-radius: 50%
  display: inline-block
  height: 10px
  margin-right: 6px
  width: 10px
</style>
