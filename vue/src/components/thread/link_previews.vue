<script lang="coffee">
import LinkPreview from '@/components/thread/link_preview'

export default
  components: {LinkPreview}
  props:
    model: Object
    remove:
      default: null
      type: Function
</script>
<template lang="pug">
.link-previews.mb-3
  link-preview(v-for="preview in model.linkPreviews"
               :key="preview.url"
               :model="model"
               :preview="preview"
               :remove="remove")
</template>
