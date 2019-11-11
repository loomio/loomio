<script lang="coffee">
export default
  props:
    files: Array
  methods:
    progressStyle: (width) ->
      {'background-color': @$vuetify.theme.accent, 'width': width+'%'}
</script>

<template lang="pug">
.files-list(v-if="files.length")
  ul
    li(v-for="wrapper in files" :key="wrapper.key")
      .files-list__item
        v-icon.files-list__icon mdi-image
        a.files-list__file-name(v-if="wrapper.blob" :href="wrapper.blob.download_url" target="_blank") {{wrapper.file.name}}
        span.files-list__file-name(v-if="!wrapper.blob") {{wrapper.file.name}}
        progress(v-if="!wrapper.blob" max="100" :value="wrapper.percentComplete")
        v-btn.files-list__remove(icon @click="$emit('removeFile', wrapper.file.name)")
          v-icon mdi-close
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
.files-list__icon
.files-list__item
	display: flex
	align-items: center
.files-list__file-name
	flex-grow: 1
.files-list__progress
	flex-grow: 1
	display: flex
	height: 16px
.files-list__progress-bar
	width: 0
	transition: width 120ms ease-out, opacity 60ms 60ms ease-in
.files-list__remove


</style>
