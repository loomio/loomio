<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    close: Function

  mounted: ->
    Records.users.removeExperience('show_vue_upgraded_modal')

</script>

<template lang="pug">
v-card.vue-upgraded-modal
  v-card-text
    v-layout(column)
      v-img(src='https://www.loomio.org/assets/loomio_org/high-five-819621bc73330bb853dd3cb1a5a9b273e2a01004d955678257dbfc139618528f.gif')
      h1.mb-8(v-t="'vue_upgraded_modal.title'")
      div(v-html="$t('vue_upgraded_modal.body', {link: 'https://blog.loomio.org/2019/09/18/what-is-new-in-loomio-2.0-and-beta-release/'})")
      v-btn.mt-4(block color="accent" v-t="'common.ok_got_it'" @click="close()")
</template>
