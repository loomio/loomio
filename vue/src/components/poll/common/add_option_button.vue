<script lang="coffee">
import EventBus from '@/shared/services/event_bus'

export default
  props:
    poll: Object
  methods:
    open: ->
      EventBus.$emit 'openModal',
        component: 'PollCommonAddOptionModal'
        props:
          poll: @poll.clone()
</script>

<template lang='pug'>
.poll-common-add-option-button(v-if='poll.voterCanAddOptions')
  v-btn(outlined rounded color="accent" @click='open()', v-t="'poll_common_add_option.button.add_option'")
</template>
