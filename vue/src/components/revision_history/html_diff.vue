<script lang="coffee">
import htmlDiff from "@/shared/helpers/html_diff"

export default
  props:
    before: String
    after: String
  methods:
    diff: -> htmlDiff(@before or '', @after)

</script>
<template lang="pug">
.html-diff(v-html='diff()')
</template>

<style lang="sass">
.html-diff
  ins
    background: lighten(green, 50%)
    margin: 2px
    padding: 0 4px
  del
    background: lighten(red, 20%)
    margin: 2px
    padding: 0 4px
  td.diff-ins
    background: lighten(green, 55%)
  td.diff-del
    background: lighten(red, 30%)
</style>
