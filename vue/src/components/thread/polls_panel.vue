<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import Session       from '@/shared/services/session'
import { debounce, some, every, compact, omit, values, keys, intersection, uniq, escapeRegExp, reject, filter} from 'lodash'
import { subDays } from 'date-fns'

export default
  props:
    discussion: Object

  data: ->
    polls: []

  created: ->
    @watchRecords
      collections: ['polls', 'groups', 'memberships', 'stances']
      query: => @findRecords()

  methods:
    findRecords: ->
      groupIds = Session.user().groupIds()

      chain = Records.polls.collection.chain()
      chain = chain.find(discardedAt: null)
      chain = chain.find(discussionId: @discussion.id)
      chain = chain.find($or: [{closedAt: null}, {closedAt: {$gt: subDays(new Date, 3)}}])
      chain = chain.where (p) => p.iCanVote() && !p.iHaveVoted()
      @polls = chain.simplesort('closingAt', true).data()

</script>

<template lang="pug">
.polls-panel(v-if='polls.length')
  v-list(two-line avatar)
    v-subheader(v-t="'dashboard_page.polls_to_vote_on'")
    poll-common-preview(:poll='poll' v-for='poll in polls' :key='poll.id')
</template>
