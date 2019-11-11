<script lang="coffee">
import Session from '@/shared/services/session'
import PollModal from '@/mixins/poll_modal'
import { orderBy } from 'lodash'

export default
  mixins: [PollModal]
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')

  props:
    stance: Object
    reasonOnly:
      type: Boolean
      default: false

  methods:
    showChoice: (choice) ->
      (choice.score > 0) or @stance.poll().pollType == "score"

  computed:
    canEdit: ->
      @stance.latest && @stance.participant() == Session.user()

    orderedStanceChoices: ->
      order = if @stance.poll().pollType == 'ranked_choice'
        'asc'
      else
        'desc'
      orderBy @stance.stanceChoices(), 'rankOrScore', order
</script>

<template lang="pug">
.poll-common-stance
  span.caption(v-if='stance.stanceChoices().length == 0' v-t="'poll_common_votes_panel.none_of_the_above'" )
  v-layout(v-if="!reasonOnly" wrap align-center)
    poll-common-stance-choice(:stance-choice='choice' v-if='showChoice(choice)' v-for='choice in orderedStanceChoices' :key='choice.id')
  formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
</template>
