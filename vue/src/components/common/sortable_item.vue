<script lang="coffee">
import { ElementMixin, HandleDirective } from 'vue-slicksort';

export default
  mixins: [ElementMixin]
  directives: { handle: HandleDirective },
  props:
    item: Object
</script>

<template lang="pug">
.sortable-list-item
  slot
</template>

<style lang="sass">
body > .sortable-list-item
  z-index: 999
</style>
