<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-action-panel__anonymous-message.lmo-hint-text
  strong(v-t="'poll_common_action_panel.anonymous'", v-if='!poll.customFields.deanonymize_after_close')
  strong(v-t="'poll_common_action_panel.anonymous_until_close'", v-if='poll.customFields.deanonymize_after_close')
</template>
