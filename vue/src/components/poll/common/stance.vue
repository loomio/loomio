<script lang="coffee">
import Session from '@/shared/services/session'

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')

  props:
    stance: Object

  computed:
    ownStance: ->
      @stance.participant == Session.user()

    orderedStanceChoices: ->
      sortBy @stance.stanceChoices(), 'rank'

# proposal, check to show icon + reason to right
# multiple option things show proportial bars and reason under
</script>

<template lang="pug">
.poll-common-stance
  //-   poll-common-directive(:size="48" :stanceChoice='choice', name='stance-choice', v-if='choice.id && choice.score > 0', v-for='choice in orderedStanceChoices', :key='choice.id')
  //-   p.lmo-markdown-wrapper {{stance.reason}}
  //-   v-btn(v-if="ownStance" outlined color='accent', @click='openEditVoteModal(stance)', v-t="'common.action.edit'")
  span.lmo-hint-text(v-t="'poll_common_votes_panel.none_of_the_above'", v-if='!stance.stanceChoices().length')
  .stance-created__choices
    poll-common-directive(name='stance-choice', :stance-choice='choice', v-if='choice.score > 0', v-for='choice in stance.stanceChoices()', :key='choice.id')
  .stance-created__reason
    div(v-if="stance.stanceChoices().length == 0" v-t="'poll_common_votes_panel.none_of_the_above'" class="lmo-hint-text")
    formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")

</template>
