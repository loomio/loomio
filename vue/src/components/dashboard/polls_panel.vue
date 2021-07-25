<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import Session       from '@/shared/services/session'
import { debounce, some, every, compact, omit, values, keys, intersection, uniq, escapeRegExp } from 'lodash'
import { subDays } from 'date-fns'

export default
  data: ->
    polls: []
    loader: null

  created: ->
    @loader = new RecordLoader
      collection: 'polls'
      params:
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
      chain = chain.find(discardedAt: null)
      chain = chain.find($or: [{groupId: {$in: groupIds}}, {id: {$in: pollIds}}])
      chain = chain.find($or: [{closedAt: null}, {closedAt: {$gt: subDays(new Date, 3)}}])

      if @$route.query.q
        rx = new RegExp(escapeRegExp(@$route.query.q), 'i');
        chain = chain.find($or: [{'title': {'$regex': rx}},
                                 {'description': {'$regex': rx}}]);

      @polls = chain.simplesort('closingAt', true).data()

</script>

<template lang="pug">
.polls-panel(v-if='polls.length || loader.loading')
  v-card.mb-2
    v-list(two-line avatar)
      v-subheader(v-t="'dashboard_page.recent_polls'")
      poll-common-preview(:poll='poll' v-for='poll in polls' :key='poll.id')
      loading(v-if='loader.loading')
</template>
