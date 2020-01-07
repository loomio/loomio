<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-action-panel__anonymous-message.pb-3
  span.caption(v-t="'poll_common_action_panel.anonymous'", v-if='!poll.customFields.deanonymize_after_close')
  span.caption(v-t="'poll_common_action_panel.anonymous_until_close'", v-if='poll.customFields.deanonymize_after_close')
</template>
