<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Session      from '@/shared/services/session'
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import PollTemplateService     from '@/shared/services/poll_template_service'
import {map, without, compact} from 'lodash'

export default
  props:
    discussion: Object
    group: Object

  data: ->
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
    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) => @fillGroups()

    renderKey = 0

    @fetch()
    EventBus.$on 'refreshPollTemplates', => @fetch()

    @watchRecords
      collections: ["pollTemplates"]
      query: (records) => @query()

  methods:
    fillGroups: ->
      groups = []
      groupIds = Session.user().groupIds()
      Records.groups.collection.chain().
                   find(id: { $in: groupIds }, archivedAt: null, parentId: null).
                   data().forEach (parent) -> 
        groups.push(parent) if parent.pollTemplatesCount > 0
        Records.groups.collection.chain().
                   find(id: { $in: groupIds }, archivedAt: null, parentId: parent.id).
                   data().forEach (subgroup) ->
          groups.push(subgroup) if subgroup.pollTemplatesCount > 0
      @groups = groups

    fetch: ->
      Records.remote.fetch(path: "poll_templates", params: {group_id: @group.id} )

    query: ->
      templates = []
      @pollTemplates = switch @filter
        when 'proposal'
          Records.pollTemplates.find(pollType: {$in: ['proposal', 'question']}, discardedAt: null)
        when 'poll'
          Records.pollTemplates.find(pollType: {$in: ['score', 'poll', 'ranked_choice', 'dot_vote']}, discardedAt: null)
        when 'meeting'
          Records.pollTemplates.find(pollType: {$in: ['meeting', 'count']}, discardedAt: null) 
        when 'admin'
          Records.pollTemplates.find(discardedAt: {$ne: null})
      @actions = {}
      @pollTemplates.forEach (pollTemplate, i) =>
        @actions[i] = PollTemplateService.actions(pollTemplate, @group)

    cloneTemplate: (template) ->
      poll = template.buildPoll()
      poll.discussionId = @discussion.id if @discussion
      poll.groupId = @group.id if @group
      @$emit('setPoll', poll)

  watch:
    filter: 'query'

  computed:
    filterNames: -> Object.keys(@filters)
    filterIcons: -> Object.values(@filters)
</script>

<template lang="pug">
div
  .poll-templates-select-group
    v-list
      v-list-item(v-for="group in groups" :key="group.id")
        v-list-item-avatar(aria-hidden="true")
          group-avatar(:group="group" v-if="!group.parentId")
        v-list-item-content
          v-list-item-title {{group.name}}

  .poll-common-templates-list(v-if="true")
    v-chip(v-for="icon, name in filters" :key="name" :outlined="filter != name" @click="filter = name" :class="'poll-common-choose-template__'+name")
      v-icon(small).mr-2 {{icon}}
      span.poll-type-chip-name {{name}}
    v-list.decision-tools-card__poll-types(two-line dense)
      template(v-if="filter == 'admin'")
        v-list-item.decision-tools-card__new-template(
          :to="'/poll_templates/new?group_id='+group.id"
          :class="'decision-tools-card__poll-type--new-template'"
          :key="99999"
        )
          v-list-item-content
            v-list-item-title(v-t="'poll_common.new_poll_template'")
            v-list-item-subtitle(v-t="'poll_common.create_a_custom_process'")

        v-subheader(v-t="'poll_common.hidden_poll_templates'")

      v-list-item.decision-tools-card__poll-type(
        v-for='(template, i) in pollTemplates'
        @click="cloneTemplate(template)"
        :class="'decision-tools-card__poll-type--' + template.pollType"
        :key='template.renderKey'
      )
        v-list-item-content
          v-list-item-title {{ template.processName }}
          v-list-item-subtitle {{ template.processSubtitle }}
        v-list-item-action
          action-menu(:actions='actions[i]', small, icon, :name="$t('action_dock.more_actions')")
</template>
<style>
.poll-type-chip-name:first-letter {
  text-transform: uppercase;
}
</style>
