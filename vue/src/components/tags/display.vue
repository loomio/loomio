<script lang="coffee">
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import TagsModalMixin from '@/mixins/tags_modal'
export default
  mixins: [WatchRecords, TagsModalMixin]
  props:
    discussion: Object
  computed:
    tags: -> @discussion.tagNames || []
</script>
<template lang="pug">
.thread-tags
  v-btn(icon small @click="openTagsModal(discussion)")
    v-icon(small) mdi-tag
  v-chip.ml-1(small outlined color="accent" v-for="tag in tags" :key="tag") {{ tag }}
</template>
