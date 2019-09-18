<script lang="js">
export default {
  props: ['node', 'updateAttrs', 'view'],
  computed: {
    src: {
      get() {
        return this.node.attrs.src
      },
      set(src) {
        this.updateAttrs({
          src,
        })
      },
    },
  },
}
</script>
<template lang="pug">
<div class="iframe-container">
  <iframe class="iframe__embed" :src="src"></iframe>
</div>
</template>
<style lang="css">
.iframe-container {
  overflow: hidden;
  padding-top: 56.25%;
  position: relative;
}

.iframe-container iframe {
   border: 0;
   height: 100%;
   left: 0;
   position: absolute;
   top: 0;
   width: 100%;
}

/* 4x3 Aspect Ratio */
.iframe-container-4x3 {
  padding-top: 75%;
}
</style>
