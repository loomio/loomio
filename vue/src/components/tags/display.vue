<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    tags: Array
    showCounts: Boolean
    selected: String
    smaller: Boolean
    selected: String

</script>
<template lang="pug">
span.tags-display
  v-chip.ml-1(
    v-for="tag in tags"
    :key="tag.id"
    :outlined="tag.name != selected"
    :small="!smaller"
    :xSmall="smaller"
    :color="tag.color"
    :to="'/g/'+tag.group().key+'/tags/'+tag.name"
    :class="{'mb-1': showCounts}"
  )
    span {{ tag.name }}
    span(v-if="showCounts")
      space
      span {{tag.taggingsCount}}
</template>
