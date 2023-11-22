<script lang="js">
import { exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';

export default {
  props: {
    name: String,
    zone: String
  },
  computed: {
    time() { return exact(parseISO(this.name), this.zone); }
  }
};
</script>

<template>

<pre class="poll-meeting-time">{{time}}</pre>
</template>

<style lang="sass">
.poll-meeting-time
  // white-space: pre


</style>
