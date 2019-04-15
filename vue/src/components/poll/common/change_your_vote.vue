<script lang="coffee">
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [
    PollModalMixin
  ]
  props:
    stance: Object
  methods:
    orderedStanceChoices: ->
      _.sortBy @stance.stanceChoices(), 'rank'
</script>

<template>
    <div class="poll-common-change-your-vote">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <poll-common-directive :stance_choice="choice" name="stance-choice" v-if="choice.id && choice.score > 0" v-for="choice in orderedStanceChoices" :key="choice.id"></poll-common-directive>
      <div class="md-actions lmo-md-actions">
        <button @click="openEditVoteModal(stance)" v-t="'poll_common.change_your_stance'" aria-label="$t('poll_common.change_your_stance')" class="md-accent"></button>
      </div>
    </div>
</template>
