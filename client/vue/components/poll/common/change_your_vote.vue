<style lang="scss">
</style>

<script lang="coffee">
ModalService   = require 'shared/services/modal_service'

module.exports =
  props:
    stance: Object
  methods:
    orderedStanceChoices: ->
      _.sortBy stance.stanceChoices(), 'rank'
    openStanceForm: ->
      ModalService.open 'PollCommonEditVoteModal', stance: => @stance
</script>

<template>
    <div class="poll-common-change-your-vote">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <poll-common-directive :stance_choice="choice" name="stance_choice" v-if="choice.id && choice.score > 0" v-for="choice in orderedStanceChoices" :key="choice.id"></poll-common-directive>
      <div class="md-actions lmo-md-actions">
        <button @click="openStanceForm()" v-t="'poll_common.change_your_stance'" aria-label="$t('poll_common.change_your_stance')" class="md-accent"></button>
      </div>
    </div>
</template>
