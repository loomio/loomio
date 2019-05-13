<style lang="scss">
</style>

<script lang="coffee">
import ModalService   from '@/shared/services/modal_service'
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
  props:
    stance: Object
  methods:
    openStanceForm: ->
      @openEditVoteModal(@stance)
</script>

<template lang="pug">
.poll-common-change-your-vote
  v-btn(@click="openStanceForm()", v-t="'poll_common.change_your_stance'")
</template>
