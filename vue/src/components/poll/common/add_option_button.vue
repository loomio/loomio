<style lang="scss">
</style>

<script lang="coffee">
ModalService = require 'shared/services/modal_service'

module.exports =
  props:
    poll: Object
  methods:
    open: ->
      ModalService.open 'PollCommonAddOptionModal', poll: => @poll
</script>

<template>
    <div v-if="poll.voterCanAddOptions" class="poll-common-add-option-button lmo-flex lmo-flex__space-between">
      <div></div>
      <button @click="open()" v-t="'poll_common_add_option.button.add_option'"></button>
    </div>
</template>
