<style lang="scss">
.dismiss-modal-button {
  position: relative;
  left: 18px;
}
</style>

<script lang="coffee">
module.exports =
  props:
    close: Function
</script>

<template>
  <v-btn aria-label="close" @click="close()" class="md-icon-button dismiss-modal-button modal-cancel">
    <span v-t="'common.action.cancel'" class="sr-only"></span>
    <i class="mdi mdi-24px mdi-window-close"></i>
  </v-btn>
</template>
