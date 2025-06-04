<script lang="js">
export default {
  props: {
    loader: Object,
    obj: Object,
  }
};

</script>

<template lang="pug">
.d-flex.align-center
  .strand-item__circle.mr-2(v-if="loader.collapsed[obj.event.id]" @click.stop="loader.expand(obj.event)")
    common-icon(name="mdi-unfold-more-horizontal")
  strand-item-headline.text-medium-emphasis(:event="obj.event" :eventable="obj.eventable" collapsed)
</template>
