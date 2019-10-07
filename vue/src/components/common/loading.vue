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
  v-layout.my-4.page-loading(justify-center v-if="!until")
    v-progress-circular(indeterminate color='primary')
  slot(v-if="until")
</template>
