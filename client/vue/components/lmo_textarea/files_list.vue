<script lang="coffee">
module.exports =
  props:
    files: Array
  methods:
    progressStyle: (width) ->
      {'background-color': @$vuetify.theme.accent, 'width': width+'%'}
</script>

<template lang="pug">
.files-list(v-if="files.length")
  p(v-t='"common.attachments"')
  ul
    li.files-list__item(v-for="wrapper in files" :key="wrapper.key")
      v-icon.files-list__icon mdi-image
      span.files-list__file-name {{wrapper.file.name}} {{wrapper.percentComplete}}
      span.files-list__progress(v-if="!wrapper.blob")
        span.files-list__progress-bar(:style="progressStyle(wrapper.percentComplete)")
      v-btn.files-list__remove(icon)
        v-icon mdi-close
</template>

<style lang="scss">
@import 'variables';
.files-list {
}

.files-list__icon {
}

.files-list__item {
  display: flex;
  align-items: center;
}

.files-list__file-name {
  flex-grow: 1;
}

.files-list__progress {
  flex-grow: 1;
  display: flex;
  height: 16px;
  border: 1px solid $border-color;
}

.files-list__progress-bar {
  width: 0;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
}

.files-list__remove {
}

</style>
