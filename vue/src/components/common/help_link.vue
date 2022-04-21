<script lang="coffee">
export default
  props:
    text: String
    path: String
</script>

<template lang="pug">
.help-link.d-flex.align-center
  v-icon.mr-2 mdi-book-open-variant
  a(:href="'https://help.loomio.com/'+path"
    v-t="text"
    target="_blank")
</template>
