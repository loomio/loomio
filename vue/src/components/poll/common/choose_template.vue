<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Session      from '@/shared/services/session'
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import {map, without, compact} from 'lodash'

export default
  props:
    discussion: Object
    group: Object

  data: ->
    polls: {threadPolls: [], groupPolls: [], defaultPolls: []}
    sourceTemplate: null
    expanded: Session.user().experiences['pollTypes.expanded']

  computed:
    pollKinds: -> Object.keys(@polls).filter (key) => @polls[key].length
    i18nForKind: ->
      threadPolls: 'poll_common_action_panel.from_the_thread'
      groupPolls: {path: 'poll_common_action_panel.name_templates', args: {name: @group && @group.fullName}}
      defaultPolls: 'poll_common_action_panel.default_poll_types'
    pollTypes: ->
      if @expanded 
        ['check', 'proposal', 'poll', 'meeting', 'count', 'score', 'dot_vote', 'ranked_choice']
      else
        ['check', 'proposal', 'poll', 'meeting']

  methods:
    cloneAndUsePoll: (poll) ->
      clone = poll.cloneTemplate()
      clone.discussionId = @discussion.id if @discussion
      clone.groupId = @group.id if @group
      clone
      @$emit('setPoll', clone)

    newTemplate: ->
      poll = Records.polls.build
        pollType: 'proposal'
        template: true
      poll.applyPollTypeDefaults()
      poll.discussionId = @discussion.id if @discussion
      poll.groupId = @group.id if @group
      @$emit('setPoll', poll)

    toggleExpanded: ->
      @expanded = !@expanded
      Records.users.saveExperience('pollTypes.expanded', @expanded)

  created: ->
    exclude_types = 'group discussion stance'
    if @group && @group.id
      Records.remote.fetch(path: "polls", params: {template: 1, group_id: @group.id})

    if @discussion && @discussion.sourceTemplateId
      Records.remote.fetch(path: "polls", params: {template: 1, discussion_id: @discussion.sourceTemplateId})

    @watchRecords
      collections: ["polls"]
      query: (records) =>
        renderKey = 0
        groupId = (@discussion && @discussion.groupId) || (@group && @group.id) || null 
        discussionId = (@discussion && @discussion.id)  || null
        if @discussion && @discussion.sourceTemplateId
          @sourceTemplate = @discussion.sourceTemplate()
          @polls['threadPolls'] = Records.polls.find(
            discussionId: @discussion.sourceTemplateId
            discardedAt: null
          ).sort (a,b) =>
            return -1 if (a.id < b.id) 
            return 1 if (a.id > b.id) 
            return 0

        if @group
          @polls['groupPolls'] = Records.polls.find(
            discussionId: null
            groupId: @group.id
            template: true
            discardedAt: null
          )

        @polls['defaultPolls'] = @pollTypes.map (pollType) =>
          poll = Records.polls.build
            template: true
            pollType: pollType
            renderKey: renderKey++
          poll.applyPollTypeDefaults()
          poll

</script>

<template lang="pug">
.poll-common-templates-list
  //- v-card-title(v-t="'poll_common.poll_types'")
  template(v-for="kind in pollKinds")
    v-subheader(v-t="i18nForKind[kind]" v-if="kind == 'defaultPolls' && pollKinds.length > 1")
    v-subheader(v-if="kind == 'groupPolls'" v-t="'poll_common.custom_poll_types'")
    v-subheader(v-if="kind == 'threadPolls'" v-t="'poll_common.example_polls_from_thread_template'")
    v-list.decision-tools-card__poll-types(two-line dense)
      v-list-item.decision-tools-card__poll-type(
        @click="cloneAndUsePoll(poll)"
        :class="'decision-tools-card__poll-type--' + poll.pollType"
        v-for='poll in polls[kind]'
        :key='poll.renderKey'
      )
        v-list-item-avatar
          v-icon {{$pollTypes[poll.pollType].material_icon}}
        v-list-item-content
          v-list-item-title {{ poll.defaultedI18n('processName') }}
          v-list-item-subtitle {{ poll.template? poll.defaultedI18n('processSubtitle') : poll.title }}
      v-list-item.decision-tools-card__new-template(
        v-if="kind == 'defaultPolls' && !discussion && expanded"
        @click="newTemplate"
        :class="'decision-tools-card__poll-type--new-template'"
        :key='123'
      )
        v-list-item-avatar
          v-icon mdi-plus
        v-list-item-content
          v-list-item-title(v-t="'poll_common.new_poll_type'")
          v-list-item-subtitle(v-t="'poll_common.create_a_custom_poll_type'")  
  v-btn.text-center.poll-common-choose-template-show-more(text @click="toggleExpanded")
    span(v-t="expanded ? 'common.action.show_fewer' : 'common.action.show_more'")

</template>
