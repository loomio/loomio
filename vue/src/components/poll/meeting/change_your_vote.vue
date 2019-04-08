<style lang="scss">
</style>

<script lang="coffee">
import ModalService   from '@/shared/services/modal_service'

export default
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
