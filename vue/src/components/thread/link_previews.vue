<script lang="coffee">
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import prettyBytes from 'pretty-bytes'

export default
  props:
    model: Object
    remove:
      default: null
      type: Function
  methods:
    hostname: (url) ->
      new URL(url).host
</script>
<template lang="pug">
.link-previews.mb-3
  v-card.mt-3(outlined v-for="preview in model.linkPreviews" :key="preview.url" style="position: relative")
    v-btn(style="top: 8px; right: 8px; position: absolute; z-index: 1000" v-if="remove" icon @click="remove(preview.url)")
      v-icon(:large='!!preview.image') mdi-close-circle-outline
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
