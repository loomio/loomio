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
  });
});
</script>
<template lang="pug">
span.tags-display
  v-chip.mr-1(
    v-for="tag in tagObjects"
    :key="tag.id || tag.name"
    :size="size"
    :color="tag.color"
    :to="tag.to"
  )
    plain-text.text-on-surface(:model="tag" field="name")
</template>
