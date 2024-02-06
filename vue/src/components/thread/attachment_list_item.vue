<script lang="js">
import prettyBytes from 'pretty-bytes';
export default {
  props: {
    attachment: Object
  },

  data() {
    return {
      backgroundSize: 'contain',
      backgroundPosition: 'center'
    };
  },

  mounted() {},
    // @setBackgroundSize()

  methods: {
    prettifyBytes(s) { return prettyBytes(s); },
    setBackgroundSize() {
      if (!this.attachment.preview_url) { return; }
      const url = this.attachment.preview_url;
      const img = new Image();
      const that = this;
      img.onload = function() {
        if (Math.abs(this.width - this.height) < (this.width/3)) {
          that.backgroundSize = 'contain';
          return that.backgroundPosition = 'center';
        } else {
          that.backgroundSize = 'cover';
          return that.backgroundPosition = '0 5%';
        }
      };
      img.src = this.attachment.preview_url;
    }
  },

  watch: {
    'attachment.preview_url': 'setBackgroundSize'
  }
};
</script>
<template lang="pug">
v-card.mt-3(outlined).attachment-list-item-link
  a(:href="attachment.download_url" target="_blank")
    v-card-title
      common-icon.mr-2(small :name="'mdi-' + attachment.icon")
      span.text--secondary
        |{{ attachment.filename }}
        space
        span.text-caption
          |{{ prettifyBytes(attachment.byte_size) }}
    .attachment-list-item-image.mb-2(v-if="attachment.preview_url" :style="{'background-image': 'url('+attachment.preview_url+')', 'background-size': backgroundSize, 'background-position': backgroundPosition}")
</template>

<style lang="sass">
.attachment-list-item-link
  // opacity: 90%
  .v-card__title
    word-break: break-word
    display: block

// .attachment-list-item-link:hover
//   opacity: 100%

.attachment-list-item-link
  .v-card__subtitle
    word-break: break-word

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
