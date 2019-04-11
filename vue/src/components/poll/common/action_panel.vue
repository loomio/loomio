<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import { myLastStanceFor } from '@/shared/helpers/poll'

export default
  props:
    poll: Object

  data: ->
    stance: @getLastStance()

  created: ->
    EventBus.$on 'refreshStance', @refreshStance

  computed:
    userHasVoted: ->
      myLastStanceFor(@poll)?
    userCanParticipate: ->
      AbilityService.canParticipateInPoll(@poll)

  methods:
    refreshStance: -> @stance = @getLastStance()
    getLastStance: ->
      myLastStanceFor(@poll) or
                      Records.stances.build(
                        pollId:    @poll.id,
                        userId:    AppConfig.currentUserId
                      ).choose(@$route.params.poll_option_id)

</script>

<template lang="pug">
.poll-common-action-panel(v-if='!poll.closedAt')
  poll-common-directive(v-if='userHasVoted', :stance='stance', name='change-your-vote')
  div(v-show='!userHasVoted')
    poll-common-directive(v-if='userCanParticipate', :stance='stance', name='vote-form')
    .poll-common-unable-to-vote(v-if='!userCanParticipate')
      p.lmo-hint-text(v-t="'poll_common_action_panel.unable_to_vote'")
      .lmo-md-actions
        poll-common-show-results-button
        div
</template>
