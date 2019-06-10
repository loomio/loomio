<script lang="coffee">
import {compileDiffHtml} from "@/shared/helpers/text"

export default
  props:
    before: String
    after: String
  methods:
    diff: ->
      compileDiffHtml(@before, @after)
</script>
<template lang="pug">
.text-diff
  .text-diff__text(v-html='diff()')
</template>
