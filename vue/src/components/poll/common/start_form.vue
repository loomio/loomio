<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Session      from '@/shared/services/session'
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import {map, without, compact} from 'lodash'

export default
  props:
    isModal:
      type: Boolean
      default: false
    discussion:
      type: Object
      default: => {}
    group:
      type: Object
      default: => {}

  data: ->
    currentPoll: null
    newPolls: compact Object.keys(AppConfig.pollTypes).map (pollType) =>
      return null unless AppConfig.pollTypes[pollType].enabled
      poll = Records.polls.build
        pollType: pollType
        groupId: @group.id
        discussionId: @discussion.id 
      poll.applyPollTypeDefaults()
      poll

</script>

<template lang="pug">
.poll-common-start-form
  v-list.decision-tools-card__poll-types(
    v-if="!currentPoll"
    two-line dense
  )
    v-card-title(v-if="isModal")
      v-layout(justify-space-between style="align-items: center")
        .group-form__group-title
          h1.headline(v-t="'decision_tools_card.choose_type'")
        dismiss-modal-button
    v-list-item.decision-tools-card__poll-type(
      @click="currentPoll = poll"
      :class="'decision-tools-card__poll-type--' + poll.pollType"
      v-for='poll in newPolls'
      :key='poll.pollType')
      v-list-item-avatar
        v-icon {{$pollTypes[poll.pollType].material_icon}}
      v-list-item-content
        v-list-item-title(v-t="'poll_common_form.voting_methods.' + $pollTypes[poll.pollType].vote_method")
        v-list-item-subtitle(v-t="'poll_common_form.voting_methods.' + $pollTypes[poll.pollType].vote_method + '_hint'")
  poll-common-form.ma-4(
    v-if="currentPoll"
    :poll="currentPoll"
  )
</template>
