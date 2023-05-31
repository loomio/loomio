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
    pollTemplates: []
    actions: {}
    filter: 'proposal'
    filters: 
      proposal: 'mdi-thumbs-up-down'
      poll: 'mdi-poll'
      meeting: 'mdi-calendar'

  created: ->
    renderKey = 0

    Records.remote.fetch(path: "poll_templates", params: {group_id: @group.id} )

    @watchRecords
      collections: ["pollTemplates"]
      query: (records) => @query()

  methods:
    query: ->
      templates = []
      @pollTemplates = switch @filter
        when 'proposal'
          Records.pollTemplates.find(pollType: 'proposal') 
        when 'poll'
          Records.pollTemplates.find(pollType: $in: ['score', 'poll', 'ranked_choice', 'dot_vote']) 
        when 'meeting'
          Records.pollTemplates.find(pollType: $in: ['meeting', 'count']) 
        else
          Records.pollTemplates.find(groupId: null)
      @actions = {}
      @pollTemplates.forEach (pollTemplate, i) =>
        @actions[i] = PollTemplateService.actions(pollTemplate, @group)

    cloneTemplate: (template) ->
      poll = template.buildPoll()
      poll.discussionId = @discussion.id if @discussion
      poll.groupId = @group.id if @group
      @$emit('setPoll', poll)

    newCustom: ->
      template = Records.pollTemplates.build(pollType: 'proposal')
      template.applyPollTypeDefaults()
      poll = template.buildPoll()
      poll.customize = true
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
.poll-common-templates-list

  v-chip(v-for="icon, name in filters" :outlined="filter != name" @click="filter = name")
    v-icon(small).mr-2 {{icon}}
    span.poll-type-chip-name {{name}}
  v-list.decision-tools-card__poll-types(two-line dense)
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
    v-list-item.decision-tools-card__new-template(
      @click="newCustom"
      :class="'decision-tools-card__poll-type--new-template'"
      :key="123"
    )
      v-list-item-content
        v-list-item-title(v-t="'poll_common.custom_poll'")
        v-list-item-subtitle(v-t="'poll_common.create_a_custom_poll'")

</template>
<style>
.poll-type-chip-name:first-letter {
  text-transform: uppercase;
}
</style>
