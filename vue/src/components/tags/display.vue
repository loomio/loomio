<script setup lang="js">
import Records from '@/shared/services/records';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted } from 'vue';

const { tags, group, showCounts, showOrgCounts, selected, size } = defineProps({
  tags: Array,
  group: Object,
  showCounts: Boolean,
  showOrgCounts: Boolean,
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
      taggingsCount: (byName.value[name] || {}).taggingsCount
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
