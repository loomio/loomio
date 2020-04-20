<script lang="coffee">
import Session from '@/shared/services/session'
import { orderBy } from 'lodash'

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')

  props:
    stance: Object
    reasonOnly:
      type: Boolean
      default: false

  computed:
    canEdit: ->
      @stance.latest && @stance.participant() == Session.user()

</script>

<template lang="pug">
.poll-common-stance
  span.caption(v-if='!stance.castAt' v-t="'poll_common_votes_panel.undecided'" )
  span(v-else)
    span.caption(v-if='stance.castAt && stance.totalScore() == 0' v-t="'poll_common_votes_panel.none_of_the_above'" )
    v-layout(v-if="!reasonOnly" wrap align-center)
      poll-common-stance-choice(:poll="stance.poll()" :stance-choice='choice' v-if='choice.show()' v-for='choice in stance.orderedStanceChoices()' :key='choice.id')
    formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
</template>
