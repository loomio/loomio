<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'

export default
  props:
    discussionTemplate: Object

  data: ->
    group: null

  methods:
    submit: ->
      @discussionTemplate.save()

</script>
<template lang="pug">
.thread-template-form
  submit-overlay(:value="discussionTemplate.processing")

  v-card-title.px-0
    h1.text-h4(v-if="discussionTemplate.id" tabindex="-1" v-t="'discussion_form.edit_thread_template'")
    h1.text-h4(v-else tabindex="-1" v-t="'discussion_form.new_thread_template'")

  v-text-field(
     v-model="discussionTemplate.processName"
    :label="$t('poll_common_form.process_name')"
    :hint="$t('poll_common_form.process_name_hint')")
  validation-errors(:subject='discussionTemplate' field='processName')

  v-text-field(
     v-model="discussionTemplate.processSubtitle"
    :label="$t('poll_common_form.process_subtitle')"
    :hint="$t('poll_common_form.process_subtitle_hint')")
  validation-errors(:subject='discussionTemplate' field='processSubtitle')

  lmo-textarea(
    :model='discussionTemplate'
    field="processIntroduction"
    :placeholder="$t('poll_common_form.process_introduction_hint')"
    :label="$t('poll_common_form.process_introduction')"
  )
  v-text-field.thread-template-form-fields__title(
    type='text'
    required='true'
    :hint="$t('thread_template_form.example_title_hint')"
    :label="$t('thread_template_form.example_title_label')"
    v-model='discussionTemplate.title'
    maxlength='250')
  validation-errors(:subject='discussionTemplate' field='title')

  tags-field(:model="discussionTemplate")

  lmo-textarea(
    :model='discussionTemplate'
    field="description"
    :placeholder="$t('thread_template_form.example_description_placeholder')"
    :label="$t('thread_template_form.example_description_label')"
  )

  .d-flex.justify-space-between.my-4.mt-4.thread-template-form-actions
    v-spacer
    v-btn.thread-template-form__submit(
      color="primary"
      @click='submit()'
      :loading="discussionTemplate.processing"
      :disabled="!discussionTemplate.processName || !discussionTemplate.processSubtitle"
    )
      span(v-t="'common.action.save'")

</template>
