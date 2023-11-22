<script lang="js">
export default {
  props: {
    label: Object,
    loading: Boolean
  }
};
</script>

<template>

<div class="strand-item__load-more">
  <v-btn class="action-button" block="block" text="text" outlined="outlined" @click="$emit('click')" :loading="loading"><span v-t="label"></span></v-btn>
</div>
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
