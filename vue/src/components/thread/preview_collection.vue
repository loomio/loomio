<script lang="js">
import {slice, orderBy} from 'lodash-es';
export default {
  props: {
    threads: Array,
    limit: {
      type: Number,
      default: 25
    },
    order: {
      type: String,
      default: '-lastActivityAt'
    }
  },
  computed: {
    orderedThreads() {
      return slice(orderBy(this.threads, this.order), 0, this.limit);
    }
  }
};
</script>

<template lang="pug">
v-list.thread-previews(two-line)
  thread-preview(v-for="thread in orderedThreads", :key="thread.id", :thread="thread")
</template>
