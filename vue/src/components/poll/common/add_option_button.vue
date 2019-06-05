<style lang="scss">
</style>

<script lang="coffee">
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
  props:
    poll: Object
  methods:
    open: ->
      @openAddOptionModal(@poll)
</script>

<template lang='pug'>
.poll-common-add-option-button(v-if='poll.voterCanAddOptions')
  v-btn(@click='open()', v-t="'poll_common_add_option.button.add_option'")
</template>
