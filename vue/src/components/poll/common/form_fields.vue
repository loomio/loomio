<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-form-fields
  poll-common-tool-tip(:poll='poll')
  v-text-field.lmo-primary-form-input.poll-common-form-fields__title(type='text' required='true' :placeholder="$t('poll_' + poll.pollType + '_form.title_placeholder')" :label="$t('poll_common_form.title')" v-model='poll.title' maxlength='250')
  validation-errors(:subject='poll', field='title')
  lmo-textarea(:model='poll' field="details" :placeholder="'poll_' + poll.pollType + '_form.details_placeholder'", :label="'poll_common_form.details'")
</template>
