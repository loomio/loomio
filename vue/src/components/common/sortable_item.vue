<script lang="coffee">
import { ElementMixin } from 'vue-slicksort';
export default
  mixins: [ElementMixin]
  props:
    item: Object
</script>
<template lang="pug">
v-list-item.list-item
  slot
</template>
