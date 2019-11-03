<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import Session       from '@/shared/services/session'
import { debounce, some, every, compact, omit, values, keys, intersection } from 'lodash'

export default
  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    polls: []
    searchQuery: ''
    loader: null
    per: 50
    from: 0
    status: null
    pollType: null
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
        when @status == null
          true # noop
        when @status == 'active'
          chain = chain.find({'closedAt': null})
        when @status == 'closed'
          chain = chain.find({'closedAt': {$ne: null}})

      if @pollType
        chain = chain.find({'pollType': @pollType})

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

  watch:
    '$route.query':
      immediate: true
      handler: (query) ->
        @status = query.status
        @pollType = query.poll_type
        @subgroups = query.subgroups || 'mine'
        @searchQuery = query.q
        @refresh()

    searchQuery: debounce (val) ->
      @$router.replace(query: { q: val })
    , 500

    subgroups: -> @refresh()

</script>

<template lang="pug">
.polls-panel
  v-layout.py-2(align-center)
    v-menu
      template(v-slot:activator="{ on }")
        v-btn.mr-2.text-lowercase(v-on="on" text)
          span(v-if="status == 'active'" v-t="'polls_panel.open'")
          span(v-if="status == 'closed'" v-t="'polls_panel.closed'")
          span(v-if="!status" v-t="'polls_panel.any_status'")
          v-icon mdi-menu-down
      v-list(dense)
        v-list-item(:to="mergeRouteQuery({status: null })" v-t="'polls_panel.any_status'")
        v-list-item(:to="mergeRouteQuery({status: 'active'})" v-t="'polls_panel.open'")
        v-list-item(:to="mergeRouteQuery({status: 'closed'})" v-t="'polls_panel.closed'")
    v-menu
      template(v-slot:activator="{ on }")
        v-btn.mr-2.text-lowercase(v-on="on" text)
          //- span(v-t="{path: filterName(filter), args: {count: unreadCount}}")
          span(v-if="pollType" v-t="'poll_types.'+pollType")
          span(v-if="!pollType" v-t="'polls_panel.any_type'")
          v-icon mdi-menu-down
      v-list(dense)
        v-list-item(:to="mergeRouteQuery({poll_type: null})" )
          v-list-item-title(v-t="'polls_panel.any_type'")
        v-list-item(v-for="pollType in pollTypes" :key="pollType" :to="mergeRouteQuery({poll_type: pollType})" )
          v-list-item-title(v-t="'poll_types.'+pollType")
    v-text-field(clearable hide-details solo v-model="searchQuery" :placeholder="$t('navbar.search_polls', {name: group.name})" append-icon="mdi-magnify")
  v-card(outlined)
    v-list(two-line avatar v-if='polls.length')
      poll-common-preview(:poll='poll', v-for='poll in polls', :key='poll.id')

    v-alert(v-if='polls.length == 0 && !loader.loading' :value="true" color="grey" outlined icon="info" v-t="'polls_panel.no_polls'")

    v-layout(justify-center)
      v-btn.my-2(outlined color='accent' v-if="!loader.exhausted" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")
</template>
