<script lang="coffee">
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
.edit-group-button
  v-btn(color='accent' @click="isOpen = true" v-t="'group_wizard.do_it'")
  v-dialog(v-model="isOpen" max-width="600px" persistent :fullscreen="$vuetify.breakpoint.smAndDown")
    group-form(:group="group.clone()" :close="close")
</template>
