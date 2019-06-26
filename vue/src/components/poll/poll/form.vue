<style lang="scss">
</style>
<script lang="coffee">
export default
  props:
    poll: Object
    back: Boolean

  computed:
    canRemovePollOptions: ->
      @poll.isNew() || (@poll.isActive() && @poll.stancesCount == 0)
</script>
<template lang="pug">
.poll-poll-form
  poll-common-form-fields(:poll="poll")
  v-combobox(v-model="poll.pollOptionNames" multiple chips deletable-chips :label="$t('poll_common_form.options')")
  poll-common-closing-at-field.md-input-compensate.md-block(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
