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
    if parseInt(@$route.query.set_outcome) == @poll.id
      EventBus.$emit 'openModal',
        component: 'PollCommonOutcomeModal'
        props:
          outcome: Records.outcomes.build(pollId: @poll.id)

    if parseInt(@$route.query.change_vote) == @poll.id
      EventBus.$emit 'openModal',
        component: 'PollCommonEditVoteModal'
        props:
          stance: @poll.myStance()

    EventBus.$on 'deleteMyStance', (pollId) =>
      if pollId == @poll.id
        @stance = null 

    @watchRecords
      collections: ["stances"]
      query: (records) =>
        if @stance && !@stance.castAt && @poll.myStance() && @poll.myStance().castAt
          @stance = @lastStanceOrNew().clone()

        if @stance && @stance.castAt && @poll.myStance() && !@poll.myStance().castAt
          @stance = @lastStanceOrNew().clone()

        if !@stance && AbilityService.canParticipateInPoll(@poll)
          @stance = @lastStanceOrNew().clone()

  methods:
    lastStanceOrNew: ->
      stance = @poll.myStance() || Records.stances.build(
        reasonFormat: Session.defaultFormat()
        pollId:    @poll.id,
        userId:    AppConfig.currentUserId
      )
      if @$route.params.poll_option_id
        stance.choose(@$route.params.poll_option_id)
      stance

</script>

<template lang="pug">
.poll-common-action-panel(v-if="!poll.closedAt" style="position: relative")
  v-alert.poll-common-action-panel__anonymous-message.mt-6(dense outlined type="info" v-if='poll.anonymous')
    span(v-t="'poll_common_action_panel.anonymous'")
      
  v-overlay.rounded.elevation-1(absolute v-if="!poll.closingAt", :opacity="0.33", :z-index="2")
    v-alert.poll-common-action-panel__results-hidden-until-vote.my-2.elevation-5(
       dense type="info"
    )
      span(v-if='poll.template' v-t="{path: 'poll_common_action_panel.voting_disabled_poll_is_template', args: {poll_type: poll.translatedPollType()}}")
      span(v-else v-t="{path: 'poll_common_action_panel.draft_mode', args: {poll_type: poll.translatedPollType()}}")
      
  template(v-else)
    .poll-common-vote-form(v-if='stance && !stance.castAt')
      h3.title.py-3(v-t="'poll_common.have_your_say'")

  poll-common-directive(:class="{'pa-2': !poll.closingAt}" v-if="stance && !stance.castAt", :stance='stance' name='vote-form')

  .poll-common-unable-to-vote(v-if='!stance')
    v-alert.my-4(type="warning" outlined dense v-t="{path: 'poll_common_action_panel.unable_to_vote', args: {poll_type: poll.translatedPollType()}}")
        
</template>
