<script setup lang="js">
import { approximate } from '@/shared/helpers/format_time';

defineProps({
  date: Date
});
</script>
<template lang="pug">
span(v-t="{path: 'common.active_time_ago', args: {time_ago: approximate(date)}}")
</template>
