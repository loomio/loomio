<script setup lang="js">
import { computed, ref, watch } from 'vue';

const PALETTE = [
  '#4f6d9a',
  '#2e7d6b',
  '#8c5a99',
  '#b86b35',
  '#3b7a9e',
  '#6d7a3c',
  '#9e4d62',
  '#5b6abf'
];

const { group, size } = defineProps({
  elevation: {
    type: Number,
    default: 0
  },
  group: Object,
  size: {
    type: Number,
    default: 24
  }
});

defineEmits(['click']);

const imageFailed = ref(false);
watch(() => group?.logoUrl, () => { imageFailed.value = false; });

const showImage = computed(() => Boolean(group?.logoUrl) && !imageFailed.value);

const initials = computed(() => {
  const words = (group?.name || '').trim().split(/[\s\-_/]+/).filter(w => /[A-Za-z0-9]/.test(w));
  if (words.length >= 2) {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
  return (words[0]?.[0] || '?').toUpperCase();
});

const badgeColor = computed(() => {
  const id = Number(group?.id);
  if (Number.isFinite(id) && id > 0) {
    return PALETTE[id % PALETTE.length];
  }
  const name = group?.name || '';
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
  }
  return PALETTE[hash % PALETTE.length];
});

const fontSize = computed(() => `${Math.max(9, Math.round(size * 0.44))}px`);
</script>

<template lang="pug">
v-avatar(:size="size" rounded="sm" :color="showImage ? 'transparent' : badgeColor" @click="$emit('click')")
  v-img(v-if="showImage" :alt="group.name" cover :src="group.logoUrl" @error="imageFailed = true")
  span.group-avatar__initials(v-else :style="{ fontSize }") {{ initials }}
</template>

<style scoped>
.group-avatar__initials {
  color: #ffffff;
  font-weight: 600;
  line-height: 1;
  letter-spacing: -0.02em;
  user-select: none;
}
</style>
