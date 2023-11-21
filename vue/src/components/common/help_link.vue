<script lang="js">
export default {
  props: {
    text: String,
    path: String
  }
}
</script>

<template lang="pug">
v-btn.help-link.text--secondary(elevation="0" :href="'https://help.loomio.com/'+path" target="_blank" :title="$t(text)")
  span(v-t="'common.help'")
  common-icon.ml-1(small name="mdi-open-in-new")
</template>

<style lang="sass">
.help-link
  a
    color: rgba(0, 0, 0, 0.6)

.theme--dark .help-link
  a
    color: rgba(255, 255, 255, 0.7)
</style>
