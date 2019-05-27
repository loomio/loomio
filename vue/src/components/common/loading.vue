<script lang="coffee">
export default
  props:
    diameter:
      type: Number
      default: 30
</script>

<template lang="pug">
    .page-loading
      v-progress-circular(indeterminate color='amber')
</template>
