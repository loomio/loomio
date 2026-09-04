<script setup lang="js">
import { ref, watch } from 'vue';
import Session from '@/shared/services/session';

const { command, items, loading, query } = defineProps({
  command: {
    type: Function,
    required: true
  },
  items: {
    type: Array,
    required: true
  },
  loading: Boolean,
  query: String
});

const currentUser = Session.user();
const selectedIndex = ref(0);

watch(() => query, () => {
  selectedIndex.value = 0;
});

watch(() => items.length, length => {
  if (selectedIndex.value >= length) {
    selectedIndex.value = Math.max(0, length - 1);
  }
});

const selectRow = row => {
  command({
    id: row.handle,
    label: row.name
  });
};

const onKeyDown = ({ event }) => {
  if (event.key === 'ArrowUp') {
    if (items.length) {
      selectedIndex.value = (selectedIndex.value + items.length - 1) % items.length;
    }
    return true;
  }

  if (event.key === 'ArrowDown') {
    if (items.length) {
      selectedIndex.value = (selectedIndex.value + 1) % items.length;
    }
    return true;
  }

  if (event.key === 'Enter' || event.key === 'Tab') {
    const row = items[selectedIndex.value];
    if (row) { selectRow(row); }
    return true;
  }

  return false;
};

defineExpose({ onKeyDown });
</script>

<template lang="pug">
v-card.suggestion-list(elevation="8" color="surface")
  v-list(v-if="items.length" bg-color="surface" density="compact" role="listbox")
    v-list-item(
      v-for="(row, index) in items"
      :key="row.handle"
      :data-mention-handle="row.handle"
      :class="{ 'v-list-item--active': selectedIndex === index }"
      :aria-selected="selectedIndex === index"
      role="option"
      @click="selectRow(row)"
      @mousedown.prevent
    )
      v-list-item-title
        | {{ row.name }}
        span.text-medium-emphasis(v-if="row.handle === currentUser.username") &nbsp; ({{ $t('common.you') }})
  v-list(v-else bg-color="surface" density="compact")
    v-list-item
      v-progress-circular(
        v-if="loading"
        indeterminate
        color="primary"
        size="24"
        width="2"
      )
      span(v-else v-t="'common.no_results_found'")

  .d-flex.justify-center
    v-progress-linear(v-if="loading" indeterminate color="primary" size="24" width="2")
</template>

<style scoped>
.suggestion-list,
.suggestion-list .v-list {
  background-color: rgb(var(--v-theme-surface)) !important;
  opacity: 1;
}

.suggestion-list {
  z-index: 10;
}
</style>
