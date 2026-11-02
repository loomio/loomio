<script setup>
import { mdiFormatHeaderPound } from '@mdi/js';

const { headings } = defineProps({headings: {type: Array, required: true}});
const emit = defineEmits(['selected']);
</script>

<template lang="pug">
v-list-item.content-heading-link(
  v-for="heading in headings"
  :key="`${heading.topic_item_id}-${heading.field}-${heading.index}`"
  :value="`heading-${heading.topic_item_id}-${heading.field}-${heading.index}`"
  tag="button"
  type="button"
  :title="heading.title"
  :prepend-icon="mdiFormatHeaderPound"
  :style="{paddingInlineStart: `${16 + (heading.level - 1) * 12}px`}"
  @click="emit('selected', heading)")
</template>

<style>
.content-heading-link {
  width: 100%;
  text-align: start;
}
</style>
