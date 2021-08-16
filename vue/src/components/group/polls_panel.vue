<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import PageLoader from '@/shared/services/page_loader'
import EventBus       from '@/shared/services/event_bus'
import Session       from '@/shared/services/session'
import { debounce, some, every, compact, omit, values, keys, intersection, uniq } from 'lodash'

export default
  data: ->
    group: null
    polls: []
    loader: null
    pollTypes: AppConfig.pollTypes
    per: 25

  created: ->
    @onQueryInput = debounce (val) =>
      @$router.replace(@mergeQuery(q: val))
    , 500

    @group = Records.groups.find(@$route.params.key)

    @initLoader()

    @watchRecords
      collections: ['polls', 'groups', 'memberships']
      query: => @findRecords()

    @loader.fetch(@page).then =>
      EventBus.$emit 'currentComponent',
        page: 'groupPage'
        title: @group.name
        group: @group

  methods:
    initLoader: ->
      @loader = new PageLoader
        path: 'polls'
        order: 'createdAt'
        params:
          exclude_types: 'group'
          group_key: @$route.params.key
          status: @$route.query.status
          poll_type: @$route.query.poll_type
          query: @$route.query.q
          subgroups: @$route.query.subgroups
          per: @per

    openSelectPollTypeModal: ->
      EventBus.$emit 'openModal',
                     component: 'PollCommonStartForm'
                     props:
                       group: @group
                       isModal: true

    findRecords: ->
      groupIds = switch (@$route.query.subgroups || 'mine')
        when 'all' then @group.organisationIds()
        when 'none' then [@group.id]
        when 'mine' then uniq([@group.id].concat(intersection(@group.organisationIds(), Session.user().groupIds())))


      chain = Records.polls.collection.chain()
      chain = chain.find(groupId: {$in: groupIds})
      chain = chain.find(discardedAt: null)

      switch @$route.query.status
        when 'active'
          chain = chain.find({'closedAt': null})
        when 'closed'
          chain = chain.find({'closedAt': {$ne: null}})
        when 'vote'
          chain = chain.find({'closedAt': null}).where((p) -> p.iCanVote() && !p.iHaveVoted())

      if @$route.query.poll_type
        chain = chain.find({'pollType': @$route.query.poll_type})

      if @$route.query.q
        chain = chain.where (poll) =>
          some [poll.title, poll.details], (field) =>
            every @$route.query.q.split(' '), (frag) -> RegExp(frag, "i").test(field)

      if @loader.pageWindow[@page]
        if @page == 1
          chain = chain.find(createdAt: {$gte: @loader.pageWindow[@page][0]})
        else
          chain = chain.find(createdAt: {$jbetween: @loader.pageWindow[@page]})
        @polls = chain.simplesort('createdAt', true).data()
      else
        @polls = []

  watch:
    '$route.query.q': ->
      @initLoader().fetch(@page)
    '$route.query.status': ->
      @initLoader().fetch(@page)
    '$route.query.poll_type': ->
      @initLoader().fetch(@page)
    '$route.query.subgroups': ->
      @initLoader().fetch(@page)

    '$route.query.page': ->
      @loader.fetch(@page)

  computed:
    totalPages: ->
      Math.ceil(parseFloat(@loader.total) / parseFloat(@per))

    canStartPoll: -> AbilityService.canStartPoll(@group)
    page:
      get: -> parseInt(@$route.query.page) || 1
      set: (val) ->
        @$router.replace
          query:
            page: val
</script>

<template lang="pug">
.polls-panel
  loading(v-if="!group")
  div(v-if="group")
    v-layout.py-2(align-center wrap)
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            span(v-if="$route.query.status == 'active'" v-t="'polls_panel.open'")
            span(v-if="$route.query.status == 'closed'" v-t="'polls_panel.closed'")
            span(v-if="$route.query.status == 'vote'" v-t="'polls_panel.need_vote'")
            span(v-if="!$route.query.status" v-t="'polls_panel.any_status'")
            v-icon mdi-menu-down
        v-list(dense)
          v-list-item(:to="mergeQuery({status: null })" v-t="'polls_panel.any_status'")
          v-list-item(:to="mergeQuery({status: 'active'})" v-t="'polls_panel.open'")
          v-list-item(:to="mergeQuery({status: 'closed'})" v-t="'polls_panel.closed'")
          v-list-item(:to="mergeQuery({status: 'vote'})" v-t="'polls_panel.need_vote'")
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            //- span(v-t="{path: filterName(filter), args: {count: unreadCount}}")
            span(v-if="$route.query.poll_type" v-t="'poll_types.'+$route.query.poll_type")
            span(v-if="!$route.query.poll_type" v-t="'polls_panel.any_type'")
            v-icon mdi-menu-down
        v-list(dense)
          v-list-item(:to="mergeQuery({poll_type: null})" )
            v-list-item-title(v-t="'polls_panel.any_type'")
          v-list-item(v-for="pollType in pollTypes" :key="pollType" :to="mergeQuery({poll_type: pollType})" )
            v-list-item-title(v-t="'poll_types.'+pollType")
      v-text-field.mr-2(clearable hide-details solo :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_polls', {name: group.name})" append-icon="mdi-magnify")
      v-btn.polls-panel__new-poll-button(@click='openSelectPollTypeModal' color='primary' v-if='canStartPoll' v-t="'polls_panel.new_poll'")
    v-card(outlined)
      div(v-if="loader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        v-list(two-line avatar v-if='polls.length && loader.pageWindow[page]')
          poll-common-preview(:poll='poll' v-for='poll in polls' :key='poll.id' :display-group-name="poll.groupId != group.id")

        p.pa-4.text-center(v-if='polls.length == 0 && !loader.loading' v-t="'polls_panel.no_polls'")
        loading(v-if="loader.loading")
        v-pagination(v-model="page" :length="totalPages" :total-visible="7" :disabled="totalPages == 1")

</template>
