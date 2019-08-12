<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import WatchRecords from '@/mixins/watch_records'
import EventBus       from '@/shared/services/event_bus'
import { debounce, some, every, compact, omit, values, keys } from 'lodash'

export default
  mixins: [WatchRecords]

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    polls: []
    search: ''
    loader: null
    per: 50
    from: 0
    filter: 'all'
    subgroups: 'none'
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
      collections: ['polls']
      query: => @query()

    @refresh()

  methods:
    refresh: ->
      @fetch()
      @query()

    query: (store) ->
      chain = Records.polls.collection.chain()
      chain = chain.find(groupId: {$in: @groupIds})

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

      if @search
        chain = chain.where (poll) =>
          some [poll.title, poll.details], (field) =>
            every @search.split(' '), (frag) -> RegExp(frag, "i").test(field)

      @polls = chain.simplesort('-createdAt').limit(@from + @per).data()

    selectFilter: (pair) ->
      name = keys(pair)[0]
      value  = values(pair)[0]

      params = omit(@$route.query, ['t', 'status', 'poll_type'])

      if value == "all"
        @$router.replace(query: params)
      else
        @$router.replace(query: Object.assign({}, params, {"#{name}": value}))

      @filter = value

    fetch: debounce ->
      @loader.fetchRecords
        group_key: @group.key
        status: @$route.query.status
        poll_type: @$route.query.poll_type
        per: @per
        from: @from
        query: @search
        subgroups: @subgroups
    ,
      300

  computed:
    groupIds: ->
      switch @subgroups
        when 'none' then [@group.id]
        when 'mine' then intersection(@group.organisationIds(), Session.user().groupIds())
        when 'all' then @group.organisationIds()

    totalRecords: -> @group.pollsCount

    showLoadMore: ->
      !@loader.loading && @loader.numRequested < @totalRecords && !@search.length

  watch:
    filter: -> @refresh()
    '$route.query.q': (val) ->
      @search = val
      @refresh()
    subgroups: -> @refresh()

</script>

<template lang="pug">
.polls-panel
  v-chip-group.pl-2(v-model="filter" active-class="accent--text")
    v-chip(label outlined value="all" @click="selectFilter({status: 'all'})")
      span(v-t="'polls_panel.all'")
    v-chip(label outlined value="active" @click="selectFilter({status: 'active'})")
      span(v-t="'polls_panel.open'")
    v-chip(label outlined value="closed" @click="selectFilter({status: 'closed'})")
      span(v-t="'polls_panel.closed'")
    v-divider.mr-2.ml-1(inset vertical)
    span(v-for="pollType in pollTypes" :key="pollType")
      v-chip(label outlined :value="pollType" @click="selectFilter({poll_type: pollType})")
        span(v-t="'poll_types.'+pollType")
    v-divider.mr-2.ml-1(inset vertical)

    v-progress-linear(color="accent" indeterminate :active="loader.loading" absolute bottom)

  v-card
    v-list(two-line avatar v-if='polls.length')
      poll-common-preview(:poll='poll', v-for='poll in polls', :key='poll.id')

    v-alert(v-if='polls.length == 0 && !loader.loading' :value="true" color="grey" outlined icon="info" v-t="'group_polls_panel.no_polls'")

    v-layout(align-center)
      span(v-if="!search" v-t="{path: 'members_panel.loaded_of_total', args: {loaded: loader.numLoaded, total: totalRecords}}")
      v-btn(v-if="showLoadMore" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")
</template>
