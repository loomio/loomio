<script setup lang="js">
import { computed } from 'vue';

const { poll, size } = defineProps({
  poll: {type: Object, required: true},
  size: {type: Number, required: true}
});

const barColor = 'rgb(var(--v-theme-info))';
const scoreData = computed(() => poll.stanceCounts.slice(0, 5));
const scoreMax = computed(() => Math.max(...scoreData.value, 0));

const bars = computed(() => {
  if (scoreData.value.length && scoreMax.value > 0) {
    const height = size / scoreData.value.length;
    return scoreData.value.map((score, index) => ({
      height: height - 2,
      width: Math.max((size * score) / scoreMax.value, 2),
      y: index * height
    }));
  }

  const height = size / 3;
  return [size, (2 * size) / 3, size / 3].map((width, index) => ({
    height: height - 2,
    width,
    y: index * height
  }));
});
</script>

<template lang="pug">
svg.bar-chart(
  :style="{height: `${size}px`, width: `${size}px`}"
  :viewBox="`0 0 ${size} ${size}`"
  aria-hidden="true")
  rect(
    v-for="(bar, index) in bars"
    :key="index"
    x="0"
    :y="bar.y"
    :width="bar.width"
    :height="bar.height"
    :fill="barColor")
</template>

<style>
.bar-chart {
  border: 0;
  margin: 0;
  padding: 0;
}
</style>
