<script lang="coffee">
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import DiscussionTemplateService from '@/shared/services/discussion_template_service'

export default
  data: ->
    templates: []
    actions: {}
    group: null

  mounted: ->
    Records.groups.findOrFetchById(parseInt(@$route.query.group_id)).then (group) =>
      @group = group

    Records.discussionTemplates.fetch
      params:
        group_id: @$route.query.group_id
        per: 50

    @watchRecords
      key: "discussionTemplates#{@$route.query.group_id}"
      collections: ['discussionTemplates', 'groups']
      query: =>
        @templates = Records.discussionTemplates.find(
          groupId: parseInt(@$route.query.group_id)
        )
        if @group
          @actions = {}
          @templates.forEach (template, i) =>
            @actions[i] = DiscussionTemplateService.actions(template, @group)

</script>
<template lang="pug">
.thread-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      div
        v-card-title
          h1.headline(tabindex="-1" v-t="'discussion_form.thread_templates'")
        v-list
          v-list-item(
            :to="'/d/new?blank_template=1&group_id='+$route.query.group_id"
          )
            v-list-item-content
              v-list-item-title(v-t="'discussion_form.blank'")
          v-list-item(
            v-for="(template, i) in templates" 
            :key="template.id"
            :to="'/d/new?template_id='+template.id"
          )
            v-list-item-content
              v-list-item-title {{template.processName}}
              v-list-item-subtitle {{template.processSubtitle}}
            v-list-item-action
              action-menu(:actions='actions[i]' small icon :name="$t('action_dock.more_actions')")
          v-list-item(
            :to="'/thread_templates/new?group_id='+$route.query.group_id"
          )
            v-list-item-content
              v-list-item-title(v-t="'discussion_form.new_template'")</template>

</template>