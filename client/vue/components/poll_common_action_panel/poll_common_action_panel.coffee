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
    stance: myLastStanceFor(@poll) or
                    Records.stances.build(
                      pollId:    @poll.id,
                      userId:    AppConfig.currentUserId
                    ).choose(LmoUrlService.params().poll_option_id)
  created: ->
    EventBus.listen @, 'refreshStance', @init
  methods:
    init: ->
      @stance = myLastStanceFor(@poll) or
                      Records.stances.build(
                        pollId:    @poll.id,
                        userId:    AppConfig.currentUserId
                      ).choose(LmoUrlService.params().poll_option_id)

    userHasVoted: ->
      myLastStanceFor(@poll)?

    userCanParticipate: ->
      AbilityService.canParticipateInPoll(@poll)
  template:
    """
    <div class="poll-common-action-panel">
      <section v-if="!poll.closedAt">
        <div v-if="userHasVoted()" class="md-block">
          <poll-common-directive :stance="stance" name="change_your_vote"></poll-common-directive>
        </div>
        <div v-show="!userHasVoted()" class="md-block">
          <poll-common-directive v-if="userCanParticipate()" :stance="stance" name="vote-form"></poll-common-directive>
          <div v-if="!userCanParticipate()" class="poll-common-unable-to-vote">
            <p v-t="'poll_common_action_panel.unable_to_vote'" class="lmo-hint-text"></p>
            <div class="lmo-md-actions">
              <poll-common-show-results-button></poll-common-show-results-button>
              <div></div>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
