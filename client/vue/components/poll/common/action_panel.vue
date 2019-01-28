<style lang="scss">
</style>

<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

{ myLastStanceFor } = require 'shared/helpers/poll'

module.exports =
  props:
    poll: Object

  data: ->
    stance: @getLastStance()
  created: ->
    EventBus.listen @, 'refreshStance', @refreshStance
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
