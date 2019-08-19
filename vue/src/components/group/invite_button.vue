<script lang="coffee">
import Records       from '@/shared/services/records'

export default
  props:
    group: Object
  data: ->
    isOpen: false
    announcement: Records.announcements.buildFromModel(@group.targetModel())
  methods:
    close: ->
      @isOpen = false
</script>
<template lang="pug">
.invite-button
  v-btn(color='accent' @click="isOpen = true" v-t="'group_page.invite_people'")
  v-dialog(v-model="isOpen" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
    announcement-form(:announcement="announcement" :close="close")
</template>
