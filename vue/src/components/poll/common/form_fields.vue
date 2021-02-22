<script lang="coffee">
export default
  props:
    poll: Object
    shouldReset: Boolean
</script>

<template lang="pug">
.poll-common-form-fields
  poll-common-tool-tip(:poll='poll')
  v-text-field.lmo-primary-form-input.poll-common-form-fields__title.text-h5(type='text' required='true' :placeholder="$t('poll_' + poll.pollType + '_form.title_placeholder')" :label="$t('poll_common_form.title')" v-model='poll.title' maxlength='250')
  validation-errors(:subject='poll', field='title')
  tags-field(:model="poll")
  lmo-textarea(:model='poll' field="details" :placeholder="$t('poll_' + poll.pollType + '_form.details_placeholder')" :label="$t('poll_common_form.details')" :should-reset="shouldReset")
</template>
