<script lang="coffee">
import prettyBytes from 'pretty-bytes'
export default
  props:
    attachment: Object

  data: ->
    backgroundSize: 'contain'
    backgroundPosition: 'center'

  mounted: ->
    # @setBackgroundSize()

  methods:
    prettifyBytes: (s) -> prettyBytes(s)
    setBackgroundSize: ->
      return unless @attachment.preview_url
      url = @attachment.preview_url
      img = new Image();
      that = @
      img.onload = ->
        if (Math.abs(@width - @height) < @width/3)
          that.backgroundSize = 'contain'
          that.backgroundPosition = 'center'
        else
          that.backgroundSize = 'cover'
          that.backgroundPosition = '0 5%'
      img.src = @attachment.preview_url

  watch:
    'attachment.preview_url': 'setBackgroundSize'
</script>
<template lang="pug">
v-card.mt-3(outlined).attachment-list-item-link
  a(:href="attachment.download_url" target="_blank")
    v-card-title
      v-icon.mr-2(small) mdi-{{attachment.icon}}
      span.text--secondary
        |{{ attachment.filename }}
        space
        span.text-caption
          |{{ prettifyBytes(attachment.byte_size) }}
    .attachment-list-item-image.mb-2(v-if="attachment.preview_url" :style="{'background-image': 'url('+attachment.preview_url+')', 'background-size': backgroundSize, 'background-position': backgroundPosition}")
</template>

<style lang="sass">
.attachment-list-item-link:hover
  background-color: #ededed

.link-preview__hostname
  word-break: break-word

.attachment-list-item-image
  background-repeat: no-repeat
  height: 128px
  overflow: none
  // background-position: center
  // max-width: 512px
  // margin: 0 auto
</style>
