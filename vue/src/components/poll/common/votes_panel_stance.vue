<style lang="scss">
.poll-common-votes-panel__stance {
  display: flex;
  align-items: flex-start;
  margin: 7px 0;
}

.poll-common-votes-panel__stance-content {
  margin-left: 10px;
}
</style>

<script lang="coffee">
{ listenForTranslations } = require 'shared/helpers/listen'
{ participantName }       = require 'shared/helpers/poll'

module.exports =
  props:
    stance: Object
  beforeCreate: ->
    @$options.components.PollCommonDirective = require('src/components/poll/common/directive.vue').default
  created: ->
    # listenForTranslations @
  computed:
    orderedStanceChoices: ->
      _.sortBy @stance.stanceChoices(), 'rank'

    participantName: -> participantName(@stance)
</script>

<template>
    <div class="poll-common-votes-panel__stance">
      <user-avatar :user="stance.participant()" size="small" class="lmo-flex__no-shrink"></user-avatar>
      <div class="poll-common-votes-panel__stance-content">
        <div class="poll-common-votes-panel__stance-name-and-option">
          <strong>{{ participantName }}</strong>
          <span v-t="'poll_common_votes_panel.none_of_the_above'" v-if="!stance.stanceChoices().length" class="lmo-hint-text"></span>
          <poll-common-directive name="stance-choice" :stance-choice="choice" v-if="choice.score > 0" v-for="choice in orderedStanceChoices" :key="choice.id"></poll-common-directive>
        </div>
        <div v-if="stance.reason" class="poll-common-votes-panel__stance-reason">
          <span v-if="!stance.translation" :marked="stance.reason" class="lmo-markdown-wrapper"></span>
          <translation v-if="stance.translation" :model="stance" field="reason"></translation>
        </div>
      </div>
    </div>
</template>
