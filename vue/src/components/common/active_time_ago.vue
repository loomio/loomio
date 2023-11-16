<script lang="js">
import { approximate } from '@/shared/helpers/format_time';

export default {
  props: {
    date: Date
  },

  methods: {
    approximate
  }
};

</script>
<template lang="pug">
span(v-t="{path: 'common.active_time_ago', args: {time_ago: approximate(date)}}")
</template>
