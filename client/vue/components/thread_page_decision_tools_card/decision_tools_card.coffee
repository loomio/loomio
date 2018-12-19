AbilityService = require 'shared/services/ability_service'

module.exports =
  props:
    discussion: Object
  methods:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)
  template:
    """
    <div v-if="canStartPoll()" class="decision-tools-card lmo-card lmo-no-print">
      <div class="lmo-flex lmo-flex__space-between">
        <h2 v-t="'decision_tools_card.title'" class="lmo-card-heading decision-tools-card__title"></h2>
        <div v-html="$t('decision_tools_card.help_text')" class="lmo-hint-text"></div>
      </div>
      <poll-common-start-form :discussion="discussion"></poll-common-start-form>
    </div>
    """
