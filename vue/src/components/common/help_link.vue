<script lang="js">
export default {
  props: {
    text: String,
    path: String
  }
}
</script>

<template>

<v-btn class="help-link text--secondary" elevation="0" :href="'https://help.loomio.com/'+path" target="_blank" :title="$t(text)"><span v-t="'common.help'"></span>
  <common-icon class="ml-1" small="small" name="mdi-open-in-new"></common-icon>
</v-btn>
</template>

<style lang="sass">
.help-link
  a
    color: rgba(0, 0, 0, 0.6)

.theme--dark .help-link
  a
    color: rgba(255, 255, 255, 0.7)
</style>
