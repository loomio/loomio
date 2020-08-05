<script lang="coffee">
export default
  props:
    helptext: String
</script>

<template lang="pug">
.help-bubble
  v-tooltip.help-bubble__tooltip(bottom)
    template(v-slot:activator="{on, attrs}")
      v-icon(v-on="on" v-bind="attrs")
        | mdi-help-circle-outline
    span(v-t="helptext")
</template>
