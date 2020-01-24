<script lang="coffee">
import { hasContent, insertContent, removeContent } from '@/shared/services/ssr_content'

export default
  props:
    until: null
    diameter:
      type: Number
      default: 30

  data: ->
    canDisplay: hasContent()

  mounted: ->
    insertContent('#loading-placeholder')

  watch:
    until: (val) -> removeContent() if val
</script>

<template lang="pug">
div
  v-layout.my-4.page-loading#loading-placeholder(justify-center v-if="!until")
    v-progress-circular(v-if="!canDisplay" indeterminate color='primary')
  slot(v-if="until")
</template>
