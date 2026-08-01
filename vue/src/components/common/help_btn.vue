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
v-btn.help-link(variant="plain" :href="'https://help.loomio.com/'+path" target="_blank")
  span(v-t="label")
  common-icon.ml-1(size="small" name="mdi-open-in-new")
</template>
