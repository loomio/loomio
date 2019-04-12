<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template>
    <div class="poll-common-action-panel__anonymous-message lmo-hint-text">
      <span v-t="'poll_common_action_panel.anonymous'" v-if="poll.customFields.denonymize_after_close"></span>
      <span v-t="'poll_common_action_panel.anonymous_until_close'" v-if="!poll.customFields.denonymize_after_close"></span>
    </div>
</template>
