<script lang="js">
export default {
  props: {
    files: Array,
  },
  methods: {
    progressStyle(width) {
      return {
        "background-color": this.$vuetify.theme.accent,
        width: width + "%",
      };
    },
  },
};
</script>

<template lang="pug">
.files-list(v-if="files.length")
  v-card.mt-3(v-for="wrapper in files" :key="wrapper.key")
    v-card-title.files-list__item.text-medium-emphasis
      common-icon.mr-2.files-list__icon(name="mdi-image")
      a.files-list__file-name(v-if="wrapper.blob" :href="wrapper.blob.download_url" target="_blank") {{wrapper.file.name}}
      span.files-list__file-name(v-if="!wrapper.blob") {{wrapper.file.name}}
      v-btn.files-list__remove(icon @click="$emit('removeFile', wrapper.file.name)" variant="tonal")
        common-icon(name="mdi-delete-outline")
    v-card-subtitle
      progress(v-if="!wrapper.blob" max="100" :value="wrapper.percentComplete")
    p(v-if="wrapper.blob && wrapper.blob.preview_url")
      img(:src="wrapper.blob.preview_url")
</template>

<style lang="sass">
.files-list
  ul
    padding-left: 0
  li
    list-style: none
  p
    img
      width: 100%
.files-list__item
  display: flex
  align-items: center
.files-list__file-name
  flex-grow: 1
  white-space: wrap
  word-wrap: break-word
.files-list__progress
  flex-grow: 1
  display: flex
  height: 16px
.files-list__progress-bar
  width: 0
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in
</style>
