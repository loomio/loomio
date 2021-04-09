<script lang="coffee">
export default
  props:
    label: Object
</script>

<template lang="pug">
.strand-item__load-more
  v-btn.action-button(text outlined @click="$emit('click')")
    //- v-icon(size="20") mdi-unfold-more-horizontal
    span(v-t="label")
</template>

<style lang="sass">
.strand-item__load-more
  // display: flex
  // align-items: center
  // min-height: 36px
  width: 100%
  // justify-content: be
  padding: 8px 0
  // background: linear-gradient(180deg, rgba(0,0,0,0) calc(50% - 1px), rgba(192,192,192,1) calc(50%), rgba(0,0,0,0) calc(50% + 1px) )
</style>
