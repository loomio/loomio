<script lang="coffee">
export default
  props:
    blockCount: Number
    lineCount: Number
  computed:
    blocks: -> new Array(@blockCount or 1)
    lines: -> new Array(@lineCount or 3)
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
</style>
