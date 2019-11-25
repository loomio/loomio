<script lang="coffee">
export default
  props:
    discussion: Object
  computed:
    tags: -> @discussion.tagNames || []
</script>
<template lang="pug">
.thread-tags
  v-chip.ml-1(small outlined color="accent" v-for="tag in tags" :key="tag" :to="{path: urlFor(discussion.group()), query: {tag: tag}}") {{ tag }}
</template>
