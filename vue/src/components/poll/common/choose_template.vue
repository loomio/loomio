<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Session      from '@/shared/services/session'
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import PollTemplateService     from '@/shared/services/poll_template_service'
import {map, without, compact} from 'lodash'
import { ContainerMixin, HandleDirective } from 'vue-slicksort'

export default
  directives:
    handle: HandleDirective

  props:
    discussion: Object
    group: Object

  data: ->
    isSorting: false
    returnTo: Session.returnTo()
    groups: []
    pollTemplates: []
    discussionTemplate: null
    actions: {}
    filter: 'proposal'
    singleList: !@group.categorizePollTemplates
    filterLabels:
      recommended: 'decision_tools_card.recommended'
      proposal: 'decision_tools_card.proposal_title'
      poll: 'decision_tools_card.poll_title'
      meeting: 'decision_tools_card.meeting'
      admin: 'group_page.settings'
      templates: 'templates.templates'

  created: ->
    Records.pollTemplates.fetchAll(@group.id)
    
    if @discussion
      Records.discussionTemplates.findOrFetchByKeyOrId(@discussion.discussionTemplateKeyOrId()).then (template) =>
        @discussionTemplate = template
        if @discussionTemplate.pollTemplateKeysOrIds.length
          @filter = 'recommended' 

    EventBus.$on 'sortPollTemplates', => @isSorting = true

    @watchRecords
      collections: ["pollTemplates"]
      query: (records) => @query()

  methods:
    query: ->
      if @filter == 'recommended'
        @pollTemplates = @discussionTemplate.pollTemplates()
      else
        if @group.categorizePollTemplates
          params = switch @filter
            when 'proposal'
              {pollType: {$in: ['proposal', 'question']}, discardedAt: null}
            when 'poll'
              {pollType: {$in: ['score', 'poll', 'ranked_choice', 'dot_vote']}, discardedAt: null}
            when 'meeting'
              {pollType: {$in: ['meeting', 'count']}, discardedAt: null}
            when 'admin'
              {discardedAt: {$ne: null}}
        else
          params = switch @filter
            when 'admin'
              {discardedAt: {$ne: null}}
            else
              {discardedAt: null}

        @pollTemplates = Records.pollTemplates.collection.chain().
          find(groupId: @group.id || null).
          find(params).
          simplesort('position').data()

      @actions = {}
      @pollTemplates.forEach (pollTemplate, i) =>
        if @filter == 'recommended'
          @actions[i] = {}
        else
          @actions[i] = PollTemplateService.actions(pollTemplate, @group)

    cloneTemplate: (template) ->
      poll = template.buildPoll()
      if @discussion
        poll.discussionId = @discussion.id 
        poll.groupId = @discussion.groupId
      else
        poll.groupId = @group.id if @group
      @$emit('setPoll', poll)

    sortEnded: ->
      @isSorting = false
      setTimeout =>
        ids = @pollTemplates.map (p) => p.id || p.key
        Records.remote.post('poll_templates/positions', group_id: @group.id, ids: ids)

  watch:
    filter: 'query'
    discussionTemplate: 'query'
    singleList: ->
      setTimeout =>
        @group.categorizePollTemplates = !@singleList
        Records.remote.post('poll_templates/settings', {group_id: @group.id, categorize_poll_templates: @group.categorizePollTemplates})

  computed:
    filters: ->
      userIsAdmin = @group.adminsInclude(Session.user())
      result = {}

      if @discussionTemplate && @discussionTemplate.pollTemplateKeysOrIds.length
        result['recommended'] =  'mdi-star'

      if @singleList 
        if userIsAdmin
          result['templates'] = 'mdi-thumbs-up-down'
          result['admin'] = 'mdi-cog'
      else
        result['proposal'] = 'mdi-thumbs-up-down'
        result['poll'] = 'mdi-poll'
        result['meeting'] = 'mdi-calendar'
        if userIsAdmin
          result['admin'] = 'mdi-cog'

      result
</script>

<template lang="pug">
.poll-common-templates-list
  .px-4
    v-chip(v-for="icon, name in filters" :key="name" :outlined="filter != name" @click="filter = name" :class="'poll-common-choose-template__'+name")
      v-icon(small).mr-2 {{icon}}
      span.poll-type-chip-name(v-t="filterLabels[name]")
  v-list.decision-tools-card__poll-types(two-line dense)
    template(v-if="filter == 'admin'")
      v-list-item.decision-tools-card__new-template(
        :to="'/poll_templates/new?group_id='+group.id+'&return_to='+returnTo"
        :class="'decision-tools-card__poll-type--new-template'"
        :key="99999"
      )
        v-list-item-content
          v-list-item-title(v-t="'discussion_form.new_template'")
          v-list-item-subtitle(v-t="'poll_common.create_a_custom_process'")

      v-checkbox.pl-4(v-model="singleList" :label="$t('poll_common.show_all_templates_in_one_list')")
      v-subheader(v-if="pollTemplates.length" v-t="'poll_common.hidden_poll_templates'")

    template(v-if="isSorting")
      sortable-list(v-model="pollTemplates"  @sort-end="sortEnded" append-to=".decision-tools-card__poll-types"  lock-axis="y" axis="y")
        sortable-item(v-for="(template, index) in pollTemplates" :index="index" :key="template.id || template.key")
          v-list-item.decision-tools-card__poll-type(

            :class="'decision-tools-card__poll-type--' + template.pollType"
            :key='template.id || template.key'
          )
            v-list-item-content
              v-list-item-title
                span {{ template.processName }}
                v-chip.ml-2(x-small outlined v-if="filter == 'admin' && !template.id" v-t="'poll_common_action_panel.default_template'")
                v-chip.ml-2(x-small outlined v-if="filter == 'admin' && template.id" v-t="'poll_common_action_panel.custom_template'")
              v-list-item-subtitle {{ template.processSubtitle }}
            v-list-item-action.handle(v-handle style="cursor: grab")
              v-icon mdi-drag-vertical
    template(v-else)
      v-list-item.decision-tools-card__poll-type(
        v-for='(template, i) in pollTemplates'
        @click="cloneTemplate(template)"
        :class="'decision-tools-card__poll-type--' + template.pollType"
        :key="template.id || template.key"
      )
        v-list-item-content
          v-list-item-title
            span {{ template.processName }}
            v-chip.ml-2(x-small outlined v-if="filter == 'admin' && !template.id" v-t="'poll_common_action_panel.default_template'")
            v-chip.ml-2(x-small outlined v-if="filter == 'admin' && template.id" v-t="'poll_common_action_panel.custom_template'")
          v-list-item-subtitle {{ template.processSubtitle }}
        v-list-item-action
          action-menu(:actions='actions[i]', small, icon, :name="$t('action_dock.more_actions')")

</template>
<style>
.decision-tools-card__poll-type {
  user-select: none;
}
</style>
