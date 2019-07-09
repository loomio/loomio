<script lang="coffee">
import { ElementMixin } from 'vue-slicksort';
export default
  mixins: [ElementMixin]
  props:
    item: Object
</script>
<template lang="pug">
v-list-item.sortable-list-item
  slot
</template>

<style lang="css">
.sortable-list-item {
  z-index: 999;
  font-family: Roboto, sans-serif !important
}
</style>
