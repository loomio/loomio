<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import { compact } from 'lodash'

export default
  props:
    discussionTemplate: Object

  data: ->
    group: null

  computed:
    breadcrumbs: ->
      compact([@discussionTemplate.group().parentId && @discussionTemplate.group().parent(), @discussionTemplate.group()]).map (g) =>
        text: g.name
        disabled: false
        to: @urlFor(g)

  methods:
    submit: ->
      @discussionTemplate.save().then (data) =>
        Flash.success "thread_template.thread_template_saved"
        @$router.push @$route.query.return_to

</script>
<template lang="pug">
.thread-template-form
  submit-overlay(:value="discussionTemplate.processing")

  .d-flex
    v-breadcrumbs.px-0.py-0(:items="breadcrumbs")
      template(v-slot:divider)
        v-icon mdi-chevron-right
    v-spacer
    v-btn.back-button(v-if="$route.query.return_to" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
      v-icon mdi-close

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
    :hint="$t('thread_template.example_title_hint')"
    :label="$t('thread_template.example_title_label')"
    v-model='discussionTemplate.title'
    maxlength='250')
  validation-errors(:subject='discussionTemplate' field='title')

  tags-field(:model="discussionTemplate")

  lmo-textarea(
    :model='discussionTemplate'
    field="description"
    :placeholder="$t('thread_template.example_description_placeholder')"
    :label="$t('thread_template.example_description_label')"
  )

  v-card-subtitle(v-t="'thread_arrangement_form.sorting'")
  v-radio-group(v-model="discussionTemplate.newestFirst")
    v-radio(:value="false")
      template(v-slot:label)
        strong(v-t="'thread_arrangement_form.earliest'")
        space
        | -
        space
        span(v-t="'thread_arrangement_form.earliest_description'")

    v-radio(:value="true")
      template(v-slot:label)
        strong(v-t="'thread_arrangement_form.latest'")
        space
        | -
        space
        span(v-t="'thread_arrangement_form.latest_description'")

  v-subheader(v-t="'thread_arrangement_form.replies'")
  v-radio-group(v-model="discussionTemplate.maxDepth")
    v-radio(:value="1")
      template(v-slot:label)
        strong(v-t="'thread_arrangement_form.linear'")
        space
        | -
        space
        span(v-t="'thread_arrangement_form.linear_description'")
    v-radio(:value="2")
      template(v-slot:label)
        strong(v-t="'thread_arrangement_form.nested_once'")
        space
        | -
        space
        span(v-t="'thread_arrangement_form.nested_once_description'")
    v-radio(:value="3")
      template(v-slot:label)
        strong(v-t="'thread_arrangement_form.nested_twice'")
        space
        | -
        space
        span(v-t="'thread_arrangement_form.nested_twice_description'")


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
