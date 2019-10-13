<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import DiscussionModalMixin     from '@/mixins/discussion_modal'
import { map, debounce, orderBy, intersection, compact, omit, identity, filter } from 'lodash'
import Session from '@/shared/services/session'

export default
  mixins: [DiscussionModalMixin]

  created: -> @init()

  data: ->
    group: null
    discussions: []
    searchResults: []
    loader: null
    searchLoader: null
    search: ''
    filter: 'open'
    subgroups: 'mine'
    showSearch: false
    groupIds: []

  methods:
    init: ->
      @group = Records.groups.fuzzyFind(@$route.params.key)

      EventBus.$emit 'currentComponent',
        page: 'groupPage'
        title: @group.name
        group: @group
        search:
          placeholder: @$t('navbar.search_threads', name: @group.parentOrSelf().name)

      EventBus.$on 'joinedGroup', (group) =>
        @fetch()

      @loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: @group.id

      @searchLoader = new RecordLoader
        collection: 'searchResults'
        params:
          subgroups: 'all'
          group_id: @group.id

      @watchRecords
        key: @group.id
        collections: ['discussions', 'groups', 'memberships']
        query: (store) => @query(store)

      @refresh()

    refresh: ->
      @from = 0
      @fetch()
      @query()

    query: (store) ->
      return unless @group
      @groupIds = switch @subgroups
        when 'mine' then intersection(@group.organisationIds(), Session.user().groupIds())
        when 'all' then @group.organisationIds()
        else [@group.id]

      if @search.length
        chain = Records.searchResults.collection.chain()
        chain = chain.find(resultGroupId: {$in: @group.parentOrSelf().organisationIds()})
        chain = chain.find(query: @search).data()
        @searchResults = orderBy(chain, 'rank', 'desc')
      else
        chain = Records.discussions.collection.chain()
        chain = chain.find(groupId: {$in: @groupIds})

        switch @filter
          when 'open'
            chain = chain.find(closedAt: null)
          when 'unread'
            chain = chain.where (discussion) -> discussion.isUnread()
          when 'closed'
            chain = chain.find(closedAt: {$ne: null})
          else
            chain = chain.find({tagNames: {'$contains': @filter}})

        chain = chain.compoundsort([['pinned', true], ['lastActivityAt', true]])

        @discussions = chain.data()

    fetch: debounce ->
      if @search
        @searchLoader.fetchRecords(q: @search)
      else
        params = {from: @from}
        params.filter = 'show_closed' if @filter == 'closed'
        params.subgroups = @subgroups
        params.tags = @tags.join("|")
        @loader.fetchRecords(params)
    ,
      300

    selectFilter: (filter) ->
      params = if filter == "open"
        omit @$route.query, ['t']
      else
        Object.assign({}, @$route.query, {t: filter})

      @$router.replace(query: params)

      @filter = filter

  watch:
    '$route.params.key': 'init'
    '$route.query':
      immediate: true
      handler: (query) ->
        @search = ''
        @filter = 'open'
        @subgroups = 'mine'

        @filter = @$route.query.t if @$route.query.t
        @search = @$route.query.q if @$route.query.q
        @subgroups = @$route.query.subgroups if @$route.query.subgroups

        @refresh()

  computed:
    tags: ->
      intersection([@filter], @groupTags)


    loading: ->
      @loader.loading || @searchLoader.loading

    noThreads: ->
      !@loading && @discussions.length == 0

    canViewPrivateContent: ->
      AbilityService.canViewPrivateContent(@group)

    canStartThread: ->
      AbilityService.canStartThread(@group)

    isLoggedIn: ->
      Session.isSignedIn()

    groupTags: ->
      @group.parentOrSelf().tagNames || []

    unreadCount: ->
      filter(@discussions, (discussion) -> discussion.isUnread()).length

</script>

<template lang="pug">
div.discussions-panel(:key="group.id")
  v-alert.white--text(color="accent" dense v-if="group.subscriptionState == 'trialing'")
    v-layout(align-center)
      span(v-t="'current_plan_button.tooltip'")
      v-spacer
      v-btn(href="/upgrade" target="_blank")
        v-icon mdi-rocket
        span(v-t="'current_plan_button.upgrade'") Upgrade
  formatted-text(v-if="group" :model="group" column="description")
  document-list(:model='group')
  attachment-list(:attachments="group.attachments")
  v-chip-group.pl-2(v-if="!search" v-model="filter" active-class="accent--text")
    v-btn.mr-4.discussions-panel__new-thread-button(@click='openStartDiscussionModal(group)' color='primary' v-if='canStartThread' v-t="'navbar.start_thread'")
    v-divider.mr-2.ml-1(inset vertical)
    v-chip(label outlined value="open" @click="selectFilter('open')")
      span(v-t="'discussions_panel.open'")
    v-chip(label outlined value="unread" @click="selectFilter('unread')")
      span(v-t="{ path: 'discussions_panel.unread', args: { count: unreadCount }}")
    v-chip(label outlined value="closed" @click="selectFilter('closed')")
      span(v-t="'discussions_panel.closed'")
    v-divider.mr-2.ml-1(inset vertical)
    v-chip(v-for="tag in groupTags" :key="tag" :value="tag" @click="selectFilter(tag)" outlined) {{tag}}

  v-card.discussions-panel
    .discussions-panel__content(v-if="!search")
      .discussions-panel__list--empty(v-if='noThreads' :value="true")
        p.text-center(v-if='canViewPrivateContent' v-t="'group_page.no_threads_here'")
        p.text-center(v-if='!canViewPrivateContent' v-t="'group_page.private_threads'")
      .discussions-panel__list.thread-preview-collection__container(v-if="discussions.length")
        v-list.thread-previews(two-line)
          thread-preview(:show-group-name="groupIds.length > 1" v-for="thread in discussions" :key="thread.id" :thread="thread" group-page)

        v-layout(justify-center)
          v-btn.my-2.discussions-panel__show-more(outlined color='accent' v-if="!loader.exhausted" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")

        .lmo-hint-text.discussions-panel__no-more-threads.text-center.pa-1(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')

    .discussions-panel__content(v-if="search")
      v-alert.text-center.discussions-panel__list--empty(v-if='!searchResults.length && !searchLoader.loading')
        p(v-t="{path: 'discussions_panel.no_results_found', args: {search: search}}")
      thread-search-result(v-for="result in searchResults" :key="result.id" :result="result")
</template>

<style lang="sass">
.discussions-panel
  div.v-slide-group__prev--disabled
    display: none

.overflow-x-auto
  overflow-x: auto
</style>
