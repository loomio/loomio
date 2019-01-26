<style lang="scss">
@import 'variables';
.decision-tools-card__poll-types {
  margin: 0;
  padding: 0;
}

.decision-tools-card__poll-type {
  color: $primary-text-color;
  list-style-type: none;
  height: 56px;
  .md-button.md-ink-ripple {
    position: absolute;
    left: 0;
  }
  .md-list-item-inner {
    margin-left: 10px;
    min-height: 56px;
  }
}

.decision-tools-card__poll-type-subtitle {
  color: $grey-on-white;
  font-weight: normal;
}

.decision-tools-card__poll-type-link {
  display: flex;
  cursor: pointer;
  text-decoration: none;
  &:hover { text-decoration: none; }
}

.decision-tools-card__poll-type-link i {
  padding: 10px 10px 10px 0;
}

.decision-tools-card__icon {
  margin-left: -16px;
}
.decision-tools-card__content {
  margin-left: 16px;
  line-height: 24px;
}
</style>

<script lang="coffee">
AbilityService = require 'shared/services/ability_service'

module.exports =
  props:
    discussion: Object
  methods:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)
</script>

<template>
  <v-card v-if="canStartPoll()" class="decision-tools-card mb-2 lmo-no-print">
    <div class="lmo-flex lmo-flex__space-between">
      <h2 v-t="'decision_tools_card.title'" class="lmo-card-heading decision-tools-card__title"></h2>
      <div v-html="$t('decision_tools_card.help_text')" class="lmo-hint-text"></div>
    </div>
    <poll-common-start-form :discussion="discussion"></poll-common-start-form>
  </v-card>
</template>
