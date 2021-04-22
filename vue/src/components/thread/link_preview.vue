<script lang="coffee">
export default
  props:
    model: Object
    preview: Object
    remove:
      default: null
      type: Function

  data: ->
    editing: false

  computed:
    hostname: ->
      new URL(@preview.url).host
</script>
<template lang="pug">
v-card.mt-3(outlined  style="position: relative")
  template(v-if="editing")
    .link-preview__image(v-if="preview.image" :style="{'background-image': 'url('+preview.image+')'}")
    v-btn(color="accent" outlined style="top: 8px; right: 8px; position: absolute; z-index: 1000" @click="editing = false")
      v-icon mdi-check
      | Done
    v-card-title
      v-text-field(filled v-model="preview.title")
    v-card-subtitle
      v-textarea(filled v-model="preview.description")

  template(v-else)
    v-btn(color="accent" style="top: 8px; right: 8px; position: absolute; z-index: 1000" v-if="remove" icon @click="remove(preview.url)")
      v-icon(:large='!!preview.image') mdi-close-circle-outline
    v-btn(color="accent" style="top: 8px; right: 64px; position: absolute; z-index: 1000" v-if="remove" icon @click="editing = true")
      v-icon(:large='!!preview.image') mdi-pencil
    a(:href="preview.url" target="_blank")
      .link-preview__image(v-if="preview.image" :style="{'background-image': 'url('+preview.image+')'}")
      v-card-title
        .d-flex
          span
            span.text--secondary {{preview.title}}
            |
            | &nbsp;
            |
            span.text-caption {{preview.hostname}}
      v-card-subtitle
        | {{preview.description}}
</template>

<style lang="sass">
.link-preview__image
  background-repeat: no-repeat
  height: 160px
  overflow: none
  background-size: cover
  background-position: top
  // max-width: 512px
  // margin: 0 auto
</style>
