<script lang="coffee">
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import DiscussionTemplateService from '@/shared/services/discussion_template_service'
import { compact } from 'lodash'

export default
  data: ->
    templates: []
    actions: {}
    group: null
    returnTo: Session.returnTo()
    isSorting: false
    showSettings: false

  mounted: ->
    Records.discussionTemplates.fetch
      params:
        group_id: @$route.query.group_id
        per: 50

    @watchRecords
      key: "discussionTemplates#{@$route.query.group_id}"
      collections: ['discussionTemplates']
      query: => @query()

    EventBus.$on 'sortThreadTemplates', => @isSorting = true

  methods:
    sortEnded: ->
      @isSorting = false
      setTimeout =>
        ids = @templates.map (p) => p.id || p.key
        Records.remote.post('discussion_templates/positions', group_id: @group.id, ids: ids)

    query: ->
      @group = Records.groups.findById(parseInt(@$route.query.group_id))
      @templates = Records.discussionTemplates.collection.chain().find(
        groupId: parseInt(@$route.query.group_id)
        discardedAt: (@showSettings && {$ne: null}) || null
      ).simplesort('position').data()

      if @group
        @actions = {}
        @templates.forEach (template, i) =>
          @actions[i] = DiscussionTemplateService.actions(template, @group)

  computed:
    userIsAdmin: ->
      @group && @group.adminsInclude(Session.user())

    breadcrumbs: ->
      return [] unless @group
      compact([@group.parentId && @group.parent(), @group]).map (g) =>
        text: g.name
        disabled: false
        to: @urlFor(g)
  watch:
    '$route.query': 'query'
    'showSettings': 'query'



</script>
<template lang="pug">
.thread-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      .d-flex
        v-breadcrumbs.px-4(:items="breadcrumbs")
          template(v-slot:divider)
            v-icon mdi-chevron-right
      v-card
        v-card-title.d-flex.pr-3
          h1.headline(v-if="!showSettings" tabindex="-1" v-t="'thread_template.start_a_new_thread'")
          h1.headline(v-if="showSettings" tabindex="-1" v-t="'thread_template.thread_template_settings'")
          v-spacer
          template(v-if="userIsAdmin")
            v-btn(v-if="!showSettings" icon @click="showSettings = true")
              v-icon mdi-cog
            v-btn(v-else icon @click="showSettings = false")
              v-icon mdi-close

        v-alert.mx-4(v-if="!showSettings && group && group.discussionsCount < 2" type="info" text outlined v-t="'thread_template.these_are_templates'") 

        template(v-if="showSettings")
          .d-flex.justify-center
            v-btn(color="primary" :to="'/thread_templates/new?group_id='+$route.query.group_id+'&return_to='+returnTo")
              span(v-t="'discussion_form.new_template'")
        v-list.append-sort-here(two-line)
          v-subheader(v-if="!showSettings" v-t="'templates.templates'")
          template(v-if="showSettings")
            v-subheader(v-if="templates.length" v-t="'thread_template.hidden_templates'")

          template(v-if="isSorting")
            sortable-list(v-model="templates"  @sort-end="sortEnded" append-to=".append-sort-here"  lock-axis="y" axis="y")
              sortable-item(v-for="(template, index) in templates" :index="index" :key="template.id || template.key")
                v-list-item(:key="template.id")
                  v-list-item-content
                    v-list-item-title {{template.processName || template.title}}
                    v-list-item-subtitle {{template.processSubtitle}}
                  v-list-item-action.handle(style="cursor: grab")
                    v-icon mdi-drag-vertical

          template(v-if="!isSorting")
            v-list-item.thread-templates--template(
              v-for="(template, i) in templates" 
              :key="template.id"
              :to="'/d/new?' + (template.id ? 'template_id='+template.id : 'template_key='+template.key)+ '&group_id='+ $route.query.group_id + '&return_to='+returnTo"
            )
              v-list-item-content
                v-list-item-title {{template.processName || template.title}}
                v-list-item-subtitle {{template.processSubtitle}}
              v-list-item-action
                action-menu(:actions='actions[i]' small icon :name="$t('action_dock.more_actions')")

      .d-flex.justify-center.my-2(v-if="!showSettings && userIsAdmin")
        v-btn(:to="'/thread_templates/browse?group_id=' + $route.query.group_id + '&return_to='+returnTo")
          span(v-t="'thread_template.browse_public_templates'")
</template>