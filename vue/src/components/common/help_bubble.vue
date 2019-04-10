<script lang="coffee">
module.exports =
  props:
    helptext: String
</script>

<template lang="pug">
.help-bubble
  v-tooltip.help-bubble__tooltip(bottom)
    v-icon(slot="activator")
      | mdi-help-circle-outline
    span(v-t="helptext")
</template>
