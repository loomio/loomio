<script lang="js">
export default {
  props: {
    until: null,
    diameter: {
      type: Number,
      default: 30
    }
  }
}
</script>

<template lang="pug">
div
  .d-flex.justify-center.my-4.page-loading(v-if="!until")
    v-progress-circular(indeterminate color='primary')
  slot(v-if="until")
</template>
