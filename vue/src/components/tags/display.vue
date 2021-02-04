<script lang="coffee">
import Records from '@/shared/services/records'
export default
  props:
    ids: Array

  computed:
    tags: ->
      Records.tags.collection.find(id: {$in: @ids}) || []

  # v-for="tag in tags" :key="tag" :to="{path: urlFor(discussion.group()), query: {tag: tag}}"
</script>
<template lang="pug">
span.tags-display
  v-chip.ml-1(v-for="tag in tags" :key="tag.id"  small outlined :color="tag.color" ) {{ tag.name }}
</template>
