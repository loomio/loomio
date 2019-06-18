<script lang="coffee">
export default
  props:
    until: null
    diameter:
      type: Number
      default: 30
</script>

<template lang="pug">
div
  .page-loading(v-if="!until")
    v-progress-circular(indeterminate color='amber')
  slot(v-if="until")
</template>
