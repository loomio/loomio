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
    backgroundSize: 'contain'
    backgroundPosition: 'center'

  mounted: ->
    @setBackgroundSize()

  methods:
    setBackgroundSize: ->
      return unless @preview.image
      url = @preview.image
      img = new Image();
      that = @
      img.onload = ->
        if (Math.abs(@width - @height) < @width/3)
          that.backgroundSize = 'contain'
          that.backgroundPosition = 'center'
        else
          that.backgroundSize = 'cover'
          that.backgroundPosition = '0 5%'
      img.src = @preview.image

  watch:
    'preview.image': 'setBackgroundSize'

  computed:
    hostname: ->
      new URL(@preview.url).host
</script>
<template lang="pug">
v-card.mt-3(outlined  style="position: relative")
  template(v-if="editing")
    .link-preview__image(v-if="preview.image" :style="{'background-image': 'url('+preview.image+')', 'background-size': backgroundSize, 'background-position': backgroundPosition}")
    v-btn(color="accent" icon outlined
          :title="$t('common.action.done')"
          style="top: 8px; right: 8px; position: absolute; z-index: 1000"
          @click="editing = false")
      v-icon mdi-check
    v-card-title
      v-text-field(filled v-model="preview.title")
    v-card-subtitle
      v-textarea(filled v-model="preview.description")

  template(v-else)
    v-btn(color="accent"
          outlined
          style="top: 8px; right: 8px; position: absolute; z-index: 1000"
          v-if="remove" icon
          @click="remove(preview.url)"
          :title="$t('common.action.remove')")
      v-icon mdi-close
    v-btn(color="accent"
          style="top: 8px; right: 48px; position: absolute; z-index: 1000"
          v-if="remove" icon
          outlined
          @click="editing = true"
          :title="$t('common.action.edit')")
      v-icon mdi-pencil
    a(:href="preview.url" target="_blank")
      .link-preview__image(v-if="preview.image" :style="{'background-image': 'url('+preview.image+')', 'background-size': backgroundSize, 'background-position': backgroundPosition}")
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
  // background-position: center
  // max-width: 512px
  // margin: 0 auto
</style>
