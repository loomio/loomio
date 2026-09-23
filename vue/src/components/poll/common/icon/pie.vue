<script setup lang="js">
import { computed } from 'vue';

const { slices, size } = defineProps({
  slices: {type: Array, required: true},
  size: {type: Number, required: true}
});

const radius = computed(() => size / 2);
const circleColor = computed(() => slices[0]?.color || '#BBBBBB');

const arcPath = (startAngle, endAngle) => {
  const rad = Math.PI / 180;
  const x1 = radius.value + (radius.value * Math.cos(-startAngle * rad));
  const x2 = radius.value + (radius.value * Math.cos(-endAngle * rad));
  const y1 = radius.value + (radius.value * Math.sin(-startAngle * rad));
  const y2 = radius.value + (radius.value * Math.sin(-endAngle * rad));

  return [
    'M', radius.value, radius.value,
    'L', x1, y1,
    'A', radius.value, radius.value, 0, Number(endAngle - startAngle > 180), 0, x2, y2,
    'z'
  ].join(' ');
};

const segments = computed(() => {
  let startAngle = 90;

  return slices.map((slice) => {
    const endAngle = startAngle + ((360 * slice.value) / 100);
    const segment = {
      color: slice.color,
      path: arcPath(startAngle, endAngle)
    };
    startAngle = endAngle;
    return segment;
  });
});
</script>

<template lang="pug">
svg.poll-proposal-chart(
  :style="{width: `${size}px`, height: `${size}px`}"
  :viewBox="`0 0 ${size} ${size}`"
  aria-hidden="true")
  circle(
    v-if="slices.length <= 1"
    :cx="radius"
    :cy="radius"
    :r="radius"
    :fill="circleColor"
    stroke-width="0")
  path(
    v-else
    v-for="(segment, index) in segments"
    :key="index"
    :d="segment.path"
    :fill="segment.color"
    stroke-width="0")
</template>

<style>
.poll-proposal-chart {
  border: 0;
  margin: 0;
  padding: 0;
}
</style>
