<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    tags: Array
    showCounts: Boolean

</script>
<template lang="pug">
span.tags-display
  v-chip.ml-1(
    v-for="tag in tags" :key="tag.id"
    small outlined
    :color="tag.color"
    :to="'/g/'+tag.group().key+'/tags/'+tag.name"
    )
    span {{ tag.name }}
    span(v-if="showCounts")
      space
      span {{tag.taggingsCount}}
</template>
