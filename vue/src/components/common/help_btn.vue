<script setup lang="js">
defineProps({
  path: String,
  label: {
    type: String,
    default: 'common.user_guide'
  }
});
</script>

<template lang="pug">
v-btn.help-link(variant="plain" :href="'/docs/'+path" target="_blank" rel="noopener noreferrer")
  span(v-t="label")
  common-icon.ml-1(size="small" name="mdi-open-in-new")
</template>
