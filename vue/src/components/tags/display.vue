<script lang="coffee">
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
export default
  mixins: [WatchRecords]
  props:
    discussion: Object
  data: ->
    tags: []
  created: ->
    @watchRecords
      collections: ['tags', 'discussion_tags']
      query: (store) =>
        @tags = Records.discussionTags.find discussionId: @discussion.id
        console.log 'tags', @tags
</script>
<template lang="pug">
.thread-tags(v-if="tags.length")
  v-chip(close v-for="tag in tags" :key="tag.id") {{ tag.tag().name }}
</template>
<style lang="scss">
</style>
