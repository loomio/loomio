<script lang="coffee">
import Session from '@/shared/services/session'
import { orderBy } from 'lodash'

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')

  props:
    stance: Object

  computed:
    canEdit: ->
      @stance.latest && @stance.participant() == Session.user()

</script>

<template lang="pug">
.poll-common-stance
  span.caption(v-if='!stance.castAt' v-t="'poll_common_votes_panel.undecided'" )
  span(v-else)
    poll-common-stance-choices(:stance="stance")
    formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
</template>
