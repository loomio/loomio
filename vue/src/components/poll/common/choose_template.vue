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
    sorting: false
    returnTo: Session.returnTo()
    groups: []
    pollTemplates: []
    actions: {}
    filter: 'proposal'
    filters: 
      proposal: 'mdi-thumbs-up-down'
      poll: 'mdi-poll'
      meeting: 'mdi-calendar'
      admin: 'mdi-cog'

  created: ->
    renderKey = 0

    EventBus.$on 'sortPollTemplates', => @sorting = true
    @fetch()
    EventBus.$on 'refreshPollTemplates', => 
      @fetch().then => @query()
      @query()

    @watchRecords
      collections: ["pollTemplates", "groups"]
      query: (records) => @query()

  methods:
    fetch: ->
      Records.remote.fetch(path: "poll_templates", params: {group_id: @group.id} )

    query: ->
      templates = []
      @pollTemplates = switch @filter
        when 'proposal'
          Records.pollTemplates.collection.chain().find(pollType: {$in: ['proposal', 'question']}, discardedAt: null).simplesort('position').data()
        when 'poll'
          Records.pollTemplates.collection.chain().find(pollType: {$in: ['score', 'poll', 'ranked_choice', 'dot_vote']}, discardedAt: null).simplesort('position').data()
        when 'meeting'
          Records.pollTemplates.collection.chain().find(pollType: {$in: ['meeting', 'count']}, discardedAt: null) .simplesort('position').data()
        when 'admin'
          Records.pollTemplates.collection.chain().find(discardedAt: {$ne: null}).simplesort('position').data()
      @actions = {}
      @pollTemplates.forEach (pollTemplate, i) =>
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
      @sorting = false
      setTimeout =>
        ids = @pollTemplates.map (p) => p.id || p.key
        Records.remote.post('poll_templates/positions', group_id: @group.id, ids: ids)

  watch:
    filter: 'query'

  computed:
    filterNames: -> Object.keys(@filters)
    filterIcons: -> Object.values(@filters)
</script>

<template lang="pug">
.poll-common-templates-list
  v-chip(v-for="icon, name in filters" :key="name" :outlined="filter != name" @click="filter = name" :class="'poll-common-choose-template__'+name")
    v-icon(small).mr-2 {{icon}}
    span.poll-type-chip-name {{name}}
  v-list.decision-tools-card__poll-types(two-line dense)
    template(v-if="filter == 'admin'")
      v-list-item.decision-tools-card__new-template(
        :to="'/poll_templates/new?group_id='+group.id+'&return_to='+returnTo"
        :class="'decision-tools-card__poll-type--new-template'"
        :key="99999"
      )
        v-list-item-content
          v-list-item-title(v-t="'poll_common.new_poll_template'")
          v-list-item-subtitle(v-t="'poll_common.create_a_custom_process'")

      v-subheader(v-if="pollTemplates.length" v-t="'poll_common.hidden_poll_templates'")

    template(v-if="sorting")
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
            v-list-item-action.handle(v-handle)
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
.poll-type-chip-name:first-letter {
  text-transform: uppercase;
}
</style>
