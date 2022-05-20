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
    polls: compact Object.keys(AppConfig.pollTypes).map (pollType) =>
      return null unless AppConfig.pollTypes[pollType].template
      poll = Records.polls.build
        pollType: pollType
        groupId: (@discussion && @discussion.groupId) || (@group && @group.id)
        discussionId: (@discussion && @discussion.id)
      poll.applyPollTypeDefaults()
      poll

</script>

<template lang="pug">
.poll-common-templates-list
  v-card-title(v-t="'poll_common.decision_templates'")
  v-list.decision-tools-card__poll-types(two-line dense)
    v-list-item.decision-tools-card__poll-type(
      @click="$emit('setPoll', poll)"
      :class="'decision-tools-card__poll-type--' + poll.pollType"
      v-for='poll in polls'
      :key='poll.pollType'
    )
      v-list-item-avatar
        v-icon {{$pollTypes[poll.pollType].material_icon}}
      v-list-item-content
        v-list-item-title {{ poll.processName || $t(poll.config().i18n.process_name) }}
        v-list-item-subtitle {{ poll.processDescription || $t(poll.config().i18n.process_description) }}
</template>
