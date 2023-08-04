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
    returnTo: Session.returnTo()
    isSorting: false

  methods:
    sortEnded: ->
      @isSorting = false
      setTimeout =>
        ids = @templates.map (p) => p.id || p.key
        Records.remote.post('discussion_templates/positions', group_id: @group.id, ids: ids)

  mounted: ->
    EventBus.$on 'sortThreadTemplates', => @isSorting = true

    Records.discussionTemplates.fetch
      params:
        group_id: @$route.query.group_id
        per: 50

    @watchRecords
      key: "discussionTemplates#{@$route.query.group_id}"
      collections: ['discussionTemplates']
      query: =>
        @group = Records.groups.findById(parseInt(@$route.query.group_id))
        @templates = Records.discussionTemplates.collection.chain().find(
          groupId: parseInt(@$route.query.group_id)
          discardedAt: null
        ).simplesort('position').data()

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
        v-list.append-sort-here(two-line)
          template(v-if="isSorting")
            sortable-list(v-model="templates"  @sort-end="sortEnded" append-to=".append-sort-here"  lock-axis="y" axis="y")
              sortable-item(v-for="(template, index) in templates" :index="index" :key="template.id || template.key")
                v-list-item(:key="template.id")
                  v-list-item-content
                    v-list-item-title {{template.processName}}
                    v-list-item-subtitle {{template.processSubtitle}}
                  v-list-item-action.handle(v-handle)
                    v-icon mdi-drag-vertical

          template(v-else)
            v-list-item(
              v-for="(template, i) in templates" 
              :key="template.id"
              :to="'/d/new?' + (template.id ? 'template_id='+template.id : 'template_key='+template.key)+ '&group_id='+ $route.query.group_id + '&return_to='+returnTo"
            )
              v-list-item-content
                v-list-item-title {{template.processName}}
                v-list-item-subtitle {{template.processSubtitle}}
              v-list-item-action
                action-menu(:actions='actions[i]' small icon :name="$t('action_dock.more_actions')")
            v-list-item(
              :to="'/thread_templates/new?group_id='+$route.query.group_id+'&return_to='+returnTo"
            )
              v-list-item-content
                v-list-item-title(v-t="'discussion_form.new_template'")
</template>