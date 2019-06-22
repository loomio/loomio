<script lang="coffee">
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
export default
  mixins: [WatchRecords]
  props:
    discussion: Object
  computed:
    tags: -> @discussion.tagNames || []
</script>
<template lang="pug">
.thread-tags(v-if="tags.length")
  v-chip(small outlined v-for="tag in tags" :key="tag") {{ tag }}
</template>
<style lang="scss">
</style>
