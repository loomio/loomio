<script lang="coffee">
import Records       from '@/shared/services/records'

export default
  props:
    group: Object
  data: ->
    isOpen: false
  methods:
    close: ->
      @isOpen = false
</script>
<template lang="pug">
.invite-button
  v-btn(color='accent' @click="isOpen = true" v-t="'install_slack.modal_title'")
  v-dialog(v-model="isOpen" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
    install-slack-modal(:group="group" :close="close" :preventClose="true")
</template>
