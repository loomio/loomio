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
    newTemplate: null
  computed:
    pollKinds: -> Object.keys(@polls).filter (key) => @polls[key].length
    i18nForKind: ->
      threadPolls: 'poll_common_action_panel.from_the_thread'
      groupPolls: 'poll_common_action_panel.from_the_group'
      defaultPolls: 'poll_common_action_panel.default_templates'

  created: ->
    exclude_types = 'group discussion stance'
    if @group && @group.id
      Records.remote.fetch(path: "polls", params: {template: 1, group_id: @group.id, exclude_types: exclude_types})
    if @discussion && @discussion.sourceTemplateId
      Records.remote.fetch(path: "polls", params: {template: 1, discussion_id: @discussion.sourceTemplateId, exclude_types: exclude_types})
    @watchRecords
      collections: ["polls"]
      query: (records) =>
        renderKey = 0
        threadPollIds = []
        groupId = (@discussion && @discussion.groupId) || (@group && @group.id) || null 
        discussionId = (@discussion && @discussion.id)  || null
        if @discussion && @discussion.sourceTemplateId
          @polls['threadPolls'] = Records.polls.find(
            discussionId: @discussion.sourceTemplateId).map (poll) =>
              threadPollIds.push(poll.id)
              clone = poll.cloneTemplate()
              clone.renderKey == renderKey++
              clone.discussionId = discussionId
              clone.groupId = groupId
              clone

        if @group
          @polls['groupPolls'] = Records.polls.find(
            template: true,
            groupId: @group.id).filter((poll) => !threadPollIds.includes(poll.id))
          .map (poll) =>
            clone = poll.cloneTemplate()
            clone.renderKey == renderKey++
            clone.discussionId =  discussionId
            clone.groupId = groupId
            clone

        @polls['defaultPolls'] = compact Object.keys(AppConfig.pollTypes).map (pollType) =>
          return null unless AppConfig.pollTypes[pollType].template
          poll = Records.polls.build
            processTitle: @$t(AppConfig.pollTypes[pollType].defaults.process_title_i18n)
            processSubtitle: @$t(AppConfig.pollTypes[pollType].defaults.process_subtitle_i18n)
            processDescription: @$t(AppConfig.pollTypes[pollType].defaults.process_description_i18n)
            pollType: pollType
            groupId: groupId
            discussionId: discussionId
            renderKey: renderKey++
          poll.applyPollTypeDefaults()
          poll

        @newTemplate = Records.polls.build
          processTitle: @$t(AppConfig.pollTypes['proposal'].defaults.process_title_i18n)
          processSubtitle: @$t(AppConfig.pollTypes['proposal'].defaults.process_subtitle_i18n)
          processDescription: @$t(AppConfig.pollTypes['proposal'].defaults.process_description_i18n)
          pollType: 'proposal'
          template: true
          groupId: groupId
          discussionId: discussionId
          renderKey: renderKey++
        @newTemplate.applyPollTypeDefaults()
        @newTemplate

</script>

<template lang="pug">
.poll-common-templates-list
  v-card-title(v-t="'poll_common.poll_templates'")
  template(v-for="kind in pollKinds")
    v-subheader(v-t="i18nForKind[kind]")
    v-list.decision-tools-card__poll-types(two-line dense)
      v-list-item.decision-tools-card__poll-type(
        @click="$emit('setPoll', poll)"
        :class="'decision-tools-card__poll-type--' + poll.pollType"
        v-for='poll in polls[kind]'
        :key='poll.renderKey'
      )
        v-list-item-avatar
          v-icon {{$pollTypes[poll.pollType].material_icon}}
        v-list-item-content
          v-list-item-title {{ poll.processTitle }}
          v-list-item-subtitle {{ poll.processSubtitle }}
      v-list-item.decision-tools-card__new-template(
        @click="$emit('setPoll', newTemplate)"
        :class="'decision-tools-card__poll-type--new-template'"
        :key='123'
      )
        v-list-item-avatar
          v-icon mdi-plus
        v-list-item-content
          v-list-item-title New template
          v-list-item-subtitle Create a decision template with your own language and settings
</template>
