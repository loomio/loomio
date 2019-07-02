<script lang="coffee">
export default
  props:
    poll: Object
  created: ->
    @poll.customFields.max_score = @poll.customFields.max_score or 9
</script>

<template lang="pug">
.poll-score-form
  poll-common-form-fields(:poll="poll")
  poll-common-form-options-field(:poll="poll")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
