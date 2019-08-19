<script lang="coffee">
import Records       from '@/shared/services/records'

export default
  props:
    group: Object
  data: ->
    isOpen: false
    discussion: Records.discussions.build(groupId: @group.id)
  methods:
    close: ->
      @isOpen = false

</script>
<template lang="pug">
.edit-group-button
  v-btn(color='accent' @click="isOpen = true" v-t="'group_wizard.do_it'")
  v-dialog(v-model="isOpen" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
    discussion-form(:discussion="discussion" :close="close")
</template>
