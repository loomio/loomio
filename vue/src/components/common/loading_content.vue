<script lang="js">
export default {
  props: {
    blockCount: Number,
    lineCount: Number
  },
  computed: {
    blocks() { return new Array(this.blockCount || 1); },
    lines() { return new Array(this.lineCount || 3); }
  }
};
</script>
<template lang="pug">
.loading-content
  .loading-content__background-wrapper(v-for='(block, index) in blocks' :key='index')
    .loading-content__background(v-for='(line, index) in lines' :key='index')
</template>
<style lang="sass">
.loading-content__background-wrapper
  padding: 8px 0

.loading-content__background
  animation: loadingWipe 2s ease-in-out infinite
  background: linear-gradient(to right, #eeeeee 8%, #dddddd 18%, #eeeeee 33%)
  background-size: 200% 100%
  height: 12px
  margin-bottom: 10px
  box-sizing: border-box
  position: relative
  &:nth-child(3n)
    margin-right: 15px
  &:nth-child(3n+1)
    margin-right: 5px
  &:nth-child(3n+2)
    margin-right: 30px

.loading-content__background
  background: linear-gradient(to right, #eeeeee 8%, #dddddd 18%, #eeeeee 33%)

.v-theme--dark, .v-theme--darkBlue
  .loading-content__background
    background: linear-gradient(to right, #222 8%, #333 18%, #222 33%)

</style>
