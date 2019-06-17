<script lang="coffee">
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
export default
  mixins: [WatchRecords]
  props:
    discussion: Object
  computed:
    tags: -> @discussion.info.tags || []
</script>
<template lang="pug">
.thread-tags(v-if="tags.length")
  v-chip(small outline v-for="tag in tags" :key="tag") {{ tag }}
</template>
<style lang="scss">
</style>
