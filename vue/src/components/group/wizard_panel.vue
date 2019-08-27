<script lang="coffee">
export default
  props:
    title: String
    close: Function
</script>
<template lang="pug">
v-carousel-item
  v-card(height="100%" color="primary")
    v-card-title
      h1.headline(v-t="title")
      v-spacer
      dismiss-modal-button(:close="close")
    slot
</template>
