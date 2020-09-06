<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

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
      @poll.myStance() || @newStance

</script>

<template lang="pug">
.poll-common-action-panel(v-if='!poll.closedAt')
  .poll-common-action-panel__anonymous-message.py-1.caption(v-t="'poll_common_action_panel.anonymous'" v-if='stance.poll().anonymous')
  .poll-common-action-panel__results-hidden-until-closed.py-1.caption(v-t="{path: 'poll_common_action_panel.results_hidden_until_closed', args: {poll_type: stance.poll().pollType}}" v-if='stance.poll().hideResultsUntilClosed')
  .poll-common-action-panel__draft-mode.py-1.caption(v-t="{path: 'poll_common_action_panel.draft_mode', args: {poll_type: stance.poll().pollType}}" v-if='!stance.poll().closingAt')
  div(v-if="poll.closingAt" v-show='!stance.castAt')
    h3.py-3(v-t="'poll_common.have_your_say'")
    poll-common-directive(v-if='userCanParticipate' :stance='stance' name='vote-form')
    .poll-common-unable-to-vote(v-if='!userCanParticipate')
      p.lmo-hint-text(v-t="'poll_common_action_panel.unable_to_vote'")
</template>
