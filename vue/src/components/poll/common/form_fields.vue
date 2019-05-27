<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template lang="pug">
.poll-common-form-fields
  //- poll_common_tool_tip(:poll='poll')
  .md-block
    v-text-field.lmo-primary-form-input.poll-common-form-fields__title(type='text', required='true', :placeholder="'poll_' + poll.pollType + '_form.title_placeholder'", :label="'poll_common_form.title'", v-model='poll.title', ng-model-options='{ allowInvalid: true }', maxlength='250')
    validation-errors(:subject='poll', field='title')
  lmo-textarea(:model='poll' field="details" :placeholder="'poll_' + poll.pollType + '_form.details_placeholder'", :label="'poll_common_form.details'")
  //- outlet(name='after-poll-form-textarea', model='poll')
</template>
