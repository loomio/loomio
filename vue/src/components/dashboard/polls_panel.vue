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
  data: ->
    votePolls: []
    otherPolls: []
    loader: null

  created: ->
    @loader = new RecordLoader
      collection: 'polls'
      params:
        exclude_types: 'group discussion'
        status: 'recent'

    @loader.fetchRecords()

    @watchRecords
      collections: ['polls', 'groups', 'memberships', 'stances']
      query: => @findRecords()

  methods:
    findRecords: ->
      groupIds = Session.user().groupIds()
      pollIds = Records.stances.find(myStance: true).map((stance) -> stance.pollId)

      chain = Records.polls.collection.chain()
      chain = chain.find(discardedAt: null, closingAt: {$ne: null})
      chain = chain.find($or: [{groupId: {$in: groupIds}}, {id: {$in: pollIds}}])
      chain = chain.find($or: [{closedAt: null}, {closedAt: {$gt: subDays(new Date, 3)}}])

      if @$route.query.q
        rx = new RegExp(escapeRegExp(@$route.query.q), 'i');
        chain = chain.find($or: [{'title': {'$regex': rx}},
                                 {'description': {'$regex': rx}}]);

      votable = (p) => p.iCanVote() && !p.iHaveVoted()
      @votePolls = filter chain.simplesort('closingAt', true).data(), votable
      @otherPolls = reject chain.simplesort('closingAt', true).data(), votable


</script>

<template lang="pug">
.polls-panel(v-if='otherPolls.length || votePolls.length || loader.loading')
  v-card.mb-2
    v-list(two-line avatar)
      template(v-if="votePolls.length")
        v-subheader(v-t="'dashboard_page.polls_to_vote_on'")
        poll-common-preview(:poll='poll' v-for='poll in votePolls' :key='poll.id')
      template(v-if="otherPolls.length")
        v-subheader(v-t="'dashboard_page.recent_polls'")
        poll-common-preview(:poll='poll' v-for='poll in otherPolls' :key='poll.id')
      template(v-if='!votePolls.length && !otherPolls.length && loader.loading')
        v-subheader(v-t="'group_page.polls'")
        loading-content(:lineCount='2' v-for='(item, index) in [1]' :key='index' )
</template>
