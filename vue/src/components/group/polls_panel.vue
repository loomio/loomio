<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import Session       from '@/shared/services/session'
import { debounce, some, every, compact, omit, values, keys, intersection } from 'lodash'

export default
  data: ->
    group: null
    polls: []
    loader: null
    pollTypes: AppConfig.pollTypes

  created: ->
    @group = Records.groups.find(@$route.params.key)
    @initLoader().fetchRecords().then =>
      EventBus.$emit 'currentComponent',
        page: 'groupPage'
        title: @group.name
        group: @group

      @watchRecords
        collections: ['polls', 'groups', 'memberships']
        query: => @findRecords()

  methods:
    initLoader: ->
      @loader = new RecordLoader
        collection: 'polls'
        params:
          exclude_types: 'discussion group event'
          group_key: @$route.params.key
          status: @$route.query.status
          poll_type: @$route.query.poll_type
          query: @$route.query.q
          subgroups: @$route.query.subgroups
          per: 25

    openSelectPollTypeModal: ->
      EventBus.$emit 'openModal',
                     component: 'PollCommonStartForm'
                     props:
                       group: @group
                       isModal: true

    onQueryInput: (val) -> @$router.replace(@mergeQuery(q: val))

    findRecords: ->
      groupIds = switch @$route.query.subgroups
        when 'none' then [@group.id]
        when 'all' then @group.organisationIds()
        else
          intersection(@group.organisationIds(), Session.user().groupIds())

      chain = Records.polls.collection.chain()
      chain = chain.find(groupId: {$in: groupIds})

      switch @$route.query.status
        when 'active'
          chain = chain.find({'closedAt': null})
        when 'closed'
          chain = chain.find({'closedAt': {$ne: null}})

      if @$route.query.poll_type
        chain = chain.find({'pollType': @$route.query.poll_type})

      if @$route.query.q
        chain = chain.where (poll) =>
          some [poll.title, poll.details], (field) =>
            every @$route.query.q.split(' '), (frag) -> RegExp(frag, "i").test(field)

      @polls = chain.simplesort('createdAt', true).limit(@loader.params.from + @loader.params.per).data()

  watch:
    '$route.query': ->
      @initLoader().fetchRecords()

  computed:
    canStartPoll: -> AbilityService.canStartPoll(@group)

</script>

<template lang="pug">
.polls-panel
  loading(v-if="!group")
  div(v-if="group")
    v-layout.py-2(align-center wrap)
      v-menu
        template(v-slot:activator="{ on }")
          v-btn.mr-2.text-lowercase(v-on="on" text)
            span(v-if="$route.query.status == 'active'" v-t="'polls_panel.open'")
            span(v-if="$route.query.status == 'closed'" v-t="'polls_panel.closed'")
            span(v-if="!$route.query.status" v-t="'polls_panel.any_status'")
            v-icon mdi-menu-down
        v-list(dense)
          v-list-item(:to="mergeQuery({status: null })" v-t="'polls_panel.any_status'")
          v-list-item(:to="mergeQuery({status: 'active'})" v-t="'polls_panel.open'")
          v-list-item(:to="mergeQuery({status: 'closed'})" v-t="'polls_panel.closed'")
      v-menu
        template(v-slot:activator="{ on }")
          v-btn.mr-2.text-lowercase(v-on="on" text)
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
        v-list(two-line avatar v-if='polls.length')
          poll-common-preview(:poll='poll' v-for='poll in polls' :key='poll.id')

        p.pa-4.text-center(v-if='polls.length == 0 && !loader.loading' v-t="'polls_panel.no_polls'")

        v-layout(justify-center)
          v-btn.my-2(outlined color='accent' v-if="!loader.exhausted" :loading="loader.loading" @click="loader.fetchRecords()" v-t="'common.action.load_more'")
</template>
