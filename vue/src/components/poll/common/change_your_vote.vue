<script lang="coffee">
import PollModalMixin from '@/mixins/poll_modal'
import {sortBy} from 'lodash'

export default
  mixins: [ PollModalMixin ]
  props:
    stance: Object
  computed:
    orderedStanceChoices: ->
      sortBy @stance.stanceChoices(), 'rank'
</script>

<template lang="pug">
.poll-common-change-your-vote
  v-subheader(v-t="'poll_common.your_response'")
  poll-common-directive(:stance_choice='choice', name='stance-choice', v-if='choice.id && choice.score > 0', v-for='choice in orderedStanceChoices', :key='choice.id')
  v-btn(color='accent', @click='openEditVoteModal(stance)', v-t="'poll_common.change_your_stance'", aria-label="$t('poll_common.change_your_stance')")
</template>
