<script lang="js">
import htmlDiff from "@/shared/helpers/html_diff";

export default {
  props: {
    before: String,
    after: String
  },
  methods: {
    diff() { return htmlDiff(this.before || '', this.after); }
  }
}

</script>
<template lang="pug">
.html-diff(v-html='diff()')
</template>

<style lang="sass">
.html-diff
  ins
    background: rgba(128, 255, 128, 0.2)
    margin: 2px
    padding: 0 4px
    text-decoration: none
  del
    background: rgba(255, 102, 102, 0.2)
    margin: 2px
    padding: 0 4px
    text-decoration: none
  td.diff-ins
    background: rgba(128, 255, 128, 0.2)
  td.diff-del
    background: rgba(255, 102, 102, 0.2)
</style>
