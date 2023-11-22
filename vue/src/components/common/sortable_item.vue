<script lang="js">
import { ElementMixin, HandleDirective } from 'vue-slicksort';

export default
  ({
    mixins: [ElementMixin],
    directives: { handle: HandleDirective },
    props: {
      item: Object
    }
  });
</script>

<template>

<div class="sortable-list-item">
  <slot></slot>
</div>
</template>

<style lang="sass">
body > .sortable-list-item
  z-index: 999
</style>
