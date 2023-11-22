<script lang="js">
export default
{
  props: {
    files: Array
  },
  methods: {
    progressStyle(width) {
      return {'background-color': this.$vuetify.theme.accent, 'width': width+'%'};
    }
  }
};
</script>

<template>

<div class="files-list" v-if="files.length">
  <v-card class="mt-3" outlined="outlined" v-for="wrapper in files" :key="wrapper.key">
    <v-card-title class="files-list__item text--secondary">
      <common-icon class="mr-2 files-list__icon" name="mdi-image"></common-icon><a class="files-list__file-name" v-if="wrapper.blob" :href="wrapper.blob.download_url" target="_blank">{{wrapper.file.name}}</a><span class="files-list__file-name" v-if="!wrapper.blob">{{wrapper.file.name}}</span>
      <progress v-if="!wrapper.blob" max="100" :value="wrapper.percentComplete"></progress>
      <v-btn class="files-list__remove" icon="icon" @click="$emit('removeFile', wrapper.file.name)">
        <common-icon name="mdi-close"></common-icon>
      </v-btn>
    </v-card-title>
    <p v-if="wrapper.blob && wrapper.blob.preview_url"><img :src="wrapper.blob.preview_url"/></p>
  </v-card>
</div>
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
.files-list__progress
	flex-grow: 1
	display: flex
	height: 16px
.files-list__progress-bar
	width: 0
	transition: width 120ms ease-out, opacity 60ms 60ms ease-in
</style>
