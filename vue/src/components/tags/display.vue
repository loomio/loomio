<script lang="coffee">
import Records from '@/shared/services/records'
export default
  props:
    tags: Array

</script>
<template lang="pug">
span.tags-display
  v-chip.ml-1(v-for="tag in tags" :key="tag.id"  small outlined :color="tag.color" ) {{ tag.name }}
</template>
