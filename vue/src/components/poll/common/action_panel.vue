<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import { myLastStanceFor } from '@/shared/helpers/poll'
import WatchRecords from '@/mixins/watch_records'

export default
  props:
    poll: Object

  data: ->
    stance: @lastStanceOrNew()
    userCanParticipate: AbilityService.canParticipateInPoll(@poll)
    newStance: Records.stances.build(
      reasonFormat: Session.defaultFormat()
      pollId:    @poll.id,
      userId:    AppConfig.currentUserId
    ).choose(@$route.params.poll_option_id)

  created: ->
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @stance = @lastStanceOrNew()
        @userCanParticipate = AbilityService.canParticipateInPoll(@poll)

  methods:
    lastStanceOrNew: ->
      @poll.stanceFor(Session.user()) || @newStance

</script>

<template lang="pug">
.poll-common-action-panel(v-if='!poll.closedAt')
  //- poll-common-directive(v-if='userHasVoted', :stance='stance', name='change-your-vote')
  div(v-show='!stance.castAt')
    h3.py-3(v-t="'poll_common.your_response'")
    poll-common-directive(v-if='userCanParticipate' :stance='stance' name='vote-form')
    .poll-common-unable-to-vote(v-if='!userCanParticipate')
      p.lmo-hint-text(v-t="'poll_common_action_panel.unable_to_vote'")
      poll-common-show-results-button
</template>
