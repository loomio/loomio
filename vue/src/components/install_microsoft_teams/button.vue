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
  v-btn(color='accent' @click="isOpen = true" v-t="'install_microsoft.card.install_microsoft'" :disabled="group.groupIdentityFor('microsoft')")
  v-dialog(v-model="isOpen" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
    install-microsoft-teams-modal(:group="group" :close="close")
</template>
