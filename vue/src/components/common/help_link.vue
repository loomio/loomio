<script lang="js">
export default {
  props: {
    path: String
  }
}
</script>

<template lang="pug">
a.help-link.text-decoration-underline(
  style="color: inherit"
  :href="'https://help.loomio.com/en/'+path"
  target="_blank"
)
  span(v-t="'common.read_more'")
</template>
