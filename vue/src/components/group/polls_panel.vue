<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import WatchRecords from '@/mixins/watch_records'
import EventBus       from '@/shared/services/event_bus'
import Session       from '@/shared/services/session'
import { debounce, some, every, compact, omit, values, keys, intersection } from 'lodash'

export default
  mixins: [WatchRecords]

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    polls: []
    searchQuery: ''
    loader: null
    per: 50
    from: 0
    filter: 'all'
    subgroups: 'mine'
    pollTypes: AppConfig.pollTypes

  created: ->
    EventBus.$emit 'currentComponent',
      page: 'groupPage'
      title: @group.name
      group: @group
      search:
        placeholder: @$t('navbar.search_polls', name: @group.parentOrSelf().name)

    @loader = new RecordLoader
      collection: 'polls'
      path: 'search'

    @watchRecords
      collections: ['polls', 'groups', 'memberships']
      query: => @query()
    @handleQueryChange(@$route.query)
    @refresh()

  methods:
    refresh: ->
      @fetch()
      @query()

    query: (store) ->
      groupIds = switch @subgroups
        when 'none' then [@group.id]
        when 'mine' then intersection(@group.organisationIds(), Session.user().groupIds())
        when 'all' then @group.organisationIds()

      chain = Records.polls.collection.chain()
      chain = chain.find(groupId: {$in: groupIds})

      switch
        when @filter == 'all'
          true
          # do nothing
        when @filter == 'active'
          chain = chain.find({'closedAt': null})
        when @filter == 'closed'
          chain = chain.find({'closedAt': {$ne: null}})
        when @pollTypes.includes(@filter)
          chain = chain.find({'pollType': @filter})
        else
          true
          # it's a group tag

      if @searchQuery
        chain = chain.where (poll) =>
          some [poll.title, poll.details], (field) =>
            every @searchQuery.split(' '), (frag) -> RegExp(frag, "i").test(field)

      @polls = chain.simplesort('-createdAt').limit(@loader.numRequested).data()

    fetch: debounce ->
      @loader.fetchRecords
        group_key: @group.key
        status: @$route.query.status
        poll_type: @$route.query.poll_type
        per: @per
        from: @from
        query: @searchQuery
        subgroups: @subgroups
    ,
      300

    handleQueryChange: (val) ->
      @filter = val.poll_type || val.status
      @searchQuery = val.q
      @refresh()


  watch:
    '$route.query': 'handleQueryChange'

    searchQuery: debounce (val) ->
      @$router.replace(query: { q: val })
    , 500

    subgroups: -> @refresh()

</script>

<template lang="pug">
.polls-panel
  v-layout
    v-text-field(dense clearable hide-details solo v-model="searchQuery" :placeholder="$t('navbar.search_polls', {name: group.name})")
  v-card
    v-list(two-line avatar v-if='polls.length')
      poll-common-preview(:poll='poll', v-for='poll in polls', :key='poll.id')

    v-alert(v-if='polls.length == 0 && !loader.loading' :value="true" color="grey" outlined icon="info" v-t="'polls_panel.no_polls'")

    v-layout(justify-center)
      v-btn.my-2(outlined color='accent' v-if="!loader.exhausted" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")
</template>
