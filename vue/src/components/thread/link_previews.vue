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
.link-previews
  v-card.mt-4(outlined v-for="preview in model.linkPreviews" :key="preview.url" style="position: relative")
    v-btn(style="top: 8px; right: 8px; position: absolute; z-index: 1000" v-if="remove" icon @click="remove(preview.url)")
      v-icon mdi-close
    a(:href="preview.url" target="_blank")
      v-img(v-if="preview.image" :src="preview.image" height="128px")
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
</style>
