<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import I18n from '@/i18n'
import { compact } from 'lodash'
import { ContainerMixin, HandleDirective } from 'vue-slicksort'

export default
  directives:
    handle: HandleDirective

  props:
    discussionTemplate: 
      type: Object
      required: true

  data: ->
    pollTemplateItems: []
    selectedPollTemplate: null
    pollTemplates: []
    recipientAudienceItems: [{text: 'None', value: null}, {text: 'Everyone in group', value: 'group'}]

  created: ->
    @pollTemplates = @discussionTemplate.pollTemplates()
    Records.pollTemplates.fetchByGroupId(@discussionTemplate.groupId)

    @watchRecords
      collections: ["pollTemplates"]
      query: (records) => @updatePollTemplateItems()

  computed:
    breadcrumbs: ->
      compact([@discussionTemplate.group().parentId && @discussionTemplate.group().parent(), @discussionTemplate.group()]).map (g) =>
        text: g.name
        disabled: false
        to: @urlFor(g)

  methods:
    updatePollTemplateItems: ->
      @pollTemplateItems = [{text: I18n.t('thread_template.add_proposal_or_poll_template'), value: null}].concat(
        Records.pollTemplates.find(groupId: @discussionTemplate.group().id).filter( (pt) =>
          !@pollTemplates.includes(pt)
        ).map (pt) ->
          {text: pt.processName, value: pt.id || pt.key}
      )

    submit: ->
      @discussionTemplate.pollTemplateKeysOrIds = @pollTemplates.map (pt) -> pt.keyOrId()
      @discussionTemplate.save().then (data) =>
        Flash.success "thread_template.thread_template_saved"
        @$router.push @$route.query.return_to || '/thread_templates/?group_id='+@discussionTemplate.groupId

    pollTemplateSelected: (keyOrId) ->
      @pollTemplates.push(Records.pollTemplates.find(keyOrId))
      setTimeout =>
        @selectedPollTemplate = null
        @updatePollTemplateItems()

    removePollTemplate: (pollTemplate) ->
      @pollTemplates.splice(@pollTemplates.indexOf(pollTemplate), 1)
      @updatePollTemplateItems()

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
  
  v-divider.my-4

  v-text-field.thread-template-form-fields__title(
    :label="$t('thread_template.default_title_label')"
    :hint="$t('thread_template.default_title_hint')"
    v-model='discussionTemplate.title'
    maxlength='250')
  validation-errors(:subject='discussionTemplate' field='title')

  v-text-field.thread-template-form-fields__title-placeholder(
    :hint="$t('thread_template.title_placeholder_hint')"
    :label="$t('thread_template.title_placeholder_label')"
    :placeholder="$t('thread_template.title_placeholder_placeholder')"
    v-model='discussionTemplate.titlePlaceholder'
    maxlength='250')
  validation-errors(:subject='discussionTemplate' field='titlePlaceholder')


  tags-field(:model="discussionTemplate")

  lmo-textarea(
    :model='discussionTemplate'
    field="description"
    :placeholder="$t('thread_template.example_description_placeholder')"
    :label="$t('thread_template.example_description_label')"
  )

  v-select(v-model="discussionTemplate.recipientAudience" label="Notify" :items="recipientAudienceItems")

  v-divider.my-4

  v-subheader.ml-n4(v-t="'thread_template.decision_templates'")
  p.text-caption(v-t="'thread_template.decision_templates_help'")
  .decision-tools-card__poll-types
    sortable-list(v-model="pollTemplates" :useDragHandle="true" append-to=".decision-tools-card__poll-types"  lock-axis="y" axis="y")
      sortable-item(v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key")
        v-list
          v-list-item.decision-tools-card__poll-type(
            :class="'decision-tools-card__poll-type--' + template.pollType"
          )
            v-list-item-content
              v-list-item-title
                span {{ template.processName }}
              v-list-item-subtitle {{ template.processSubtitle }}
            v-list-item-action.handle(v-handle style="cursor: grab")
                v-icon mdi-drag-vertical
            v-list-item-action
              v-btn(icon @click="removePollTemplate(template)")
                v-icon mdi-close
  v-select(
    v-model="selectedPollTemplate"
    :items="pollTemplateItems"
    @change="pollTemplateSelected"
  )
  v-divider.my-4

  v-subheader.ml-n4(v-t="'thread_arrangement_form.sorting'")
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

  v-subheader.ml-n4(v-t="'thread_arrangement_form.replies'")
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

  v-checkbox(v-model="discussionTemplate.public" label="Share this template in the public template gallery")
 
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
