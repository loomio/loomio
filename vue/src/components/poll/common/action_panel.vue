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
    stance: null

  created: ->
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        if @stance && !@stance.castAt && @poll.myStance() && @poll.myStance().castAt
          @stance = @lastStanceOrNew().clone()

        if !@stance && AbilityService.canParticipateInPoll(@poll)
          @stance = @lastStanceOrNew().clone()

  methods:
    lastStanceOrNew: ->
      @poll.myStance() || Records.stances.build(
        reasonFormat: Session.defaultFormat()
        pollId:    @poll.id,
        userId:    AppConfig.currentUserId
      ).choose(@$route.params.poll_option_id)

</script>

<template lang="pug">
.poll-common-action-panel(v-if='!poll.closedAt')
  .poll-common-action-panel__anonymous-message.py-1.caption(v-t="'poll_common_action_panel.anonymous'" v-if='poll.anonymous')
  .poll-common-action-panel__results-hidden-until-closed.py-1.caption(v-t="{path: 'poll_common_action_panel.results_hidden_until_closed', args: {poll_type: poll.pollType}}" v-if='poll.hideResultsUntilClosed')
  div(v-if="poll.closingAt")
    .poll-common-vote-form(v-if='stance')
      h3.py-3(v-t="'poll_common.have_your_say'")
      poll-common-directive(:stance='stance' name='vote-form')
    .poll-common-unable-to-vote(v-if='!stance')
      p.lmo-hint-text(v-t="{path: 'poll_common_action_panel.unable_to_vote', args: {poll_type: poll.translatedPollType()}}")
</template>
