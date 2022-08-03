<script lang="coffee">
export default
  props:
    text: String
    path: String
</script>

<template lang="pug">
v-btn.help-link(:href="'https://help.loomio.com/'+path" target="_blank" v-t="'common.help'" :title="$t(text)")
</template>

<style lang="sass">
.help-link
  a
    color: rgba(0, 0, 0, 0.6)

.theme--dark .help-link
  a
    color: rgba(255, 255, 255, 0.7)
</style>