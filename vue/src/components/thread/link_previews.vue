<script lang="js">
import LinkPreview from '@/components/thread/link_preview';

export default {
  components: {LinkPreview},
  props: {
    model: Object,
    remove: {
      default: null,
      type: Function
    }
  }
};
</script>
<template>

<div class="link-previews mb-3" v-if="model.linkPreviews && model.linkPreviews.length">
  <link-preview v-for="preview in model.linkPreviews" :key="preview.url" :model="model" :preview="preview" :remove="remove"></link-preview>
</div>
</template>
