<style lang="scss">
</style>

<script lang="coffee">
ModalService   = require 'shared/services/modal_service'

module.exports =
  props:
    stance: Object
  methods:
    openStanceForm: ->
      ModalService.open 'PollCommonEditVoteModal', stance: => @stance
</script>

<template lang="pug">
.poll-common-change-your-vote
  v-btn(@click="openStanceForm()", v-t="'poll_common.change_your_stance'")
</template>
