<script lang="js">
export default {
  props: {
    path: String
  }
}
</script>

<template lang="pug">
v-btn.help-link(variant="plain" :href="'https://help.loomio.com/'+path" target="_blank")
  span(v-t="'common.help'")
  common-icon.ml-1(size="small" name="mdi-open-in-new")
</template>
