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
  v-card.mt-3(v-for="wrapper in files" :key="wrapper.localUrl || wrapper.blob.signed_id")
    v-card-title.files-list__item.text-medium-emphasis
      common-icon.mr-2.files-list__icon(name="mdi-image")
      a.files-list__file-name(v-if="wrapper.blob" :href="wrapper.localUrl || wrapper.blob.download_url" target="_blank" rel="noopener") {{wrapper.file.name}}
      span.files-list__file-name(v-if="!wrapper.blob") {{wrapper.file.name}}
      v-btn.files-list__remove(icon @click="$emit('removeFile', wrapper)" variant="tonal")
        common-icon(name="mdi-delete-outline")
    v-card-subtitle
      progress(v-if="!wrapper.blob" max="100" :value="wrapper.percentComplete")
    template(v-if="wrapper.localUrl")
      p(v-if="wrapper.file.type.startsWith('image/')")
        img(:src="wrapper.localUrl" :alt="wrapper.file.name")
      video.mb-2(v-else-if="wrapper.file.type.startsWith('video/')" :src="wrapper.localUrl" controls preload="metadata")
      audio.mb-2(v-else-if="wrapper.file.type.startsWith('audio/')" :src="wrapper.localUrl" controls preload="metadata")
    p(v-else-if="wrapper.blob?.preview_url")
      img(:src="wrapper.blob.preview_url" :alt="wrapper.file.name")
</template>

<style>
.files-list ul {
  padding-left: 0;
}
.files-list li {
  list-style: none;
}
.files-list video, .files-list audio {
  max-width: 100%;
}
.files-list p img {
  width: 100%;
}

.files-list__item {
  display: flex;
  align-items: center;
  min-width: 0;
}

.files-list__file-name {
  flex-grow: 1;
  min-width: 0;
  overflow-wrap: anywhere;
  white-space: normal;
}

.files-list__progress {
  flex-grow: 1;
  display: flex;
  height: 16px;
}

.files-list__progress-bar {
  width: 0;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
}
</style>
