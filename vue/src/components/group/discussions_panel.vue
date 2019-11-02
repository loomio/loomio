<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import DiscussionModalMixin     from '@/mixins/discussion_modal'
import { map, debounce, orderBy, intersection, compact, omit, identity, filter, concat, uniq } from 'lodash'
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
    searchQuery: ''
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
      @publicGroupIds = @group.publicOrganisationIds()

      @groupIds = switch @subgroups
        when 'mine' then uniq(concat(intersection(@group.organisationIds(), Session.user().groupIds()), @publicGroupIds)) # the groups that i'm a member of + any public groups?
        when 'all' then @group.organisationIds()
        else [@group.id]

      if @searchQuery.length
        chain = Records.searchResults.collection.chain()
        chain = chain.find(resultGroupId: {$in: @group.parentOrSelf().organisationIds()})
        chain = chain.find(query: @searchQuery).data()
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
      if @searchQuery
        @searchLoader.fetchRecords(q: @searchQuery)
      else
        params = {from: @from}
        params.filter = 'show_closed' if @filter == 'closed'
        params.subgroups = @subgroups
        # params.tags = @tags.join("|")
        @loader.fetchRecords(params)
    ,
      300

    filterName: (filter) ->
      switch filter
        when 'open' then 'discussions_panel.open'
        when 'unread' then 'discussions_panel.unread'
        when 'closed' then 'discussions_panel.closed'
        when 'subscribed' then 'change_volume_form.simple.loud'

  watch:
    '$route.params.key': 'init'
    '$route.query':
      immediate: true
      handler: (query) ->
        @searchQuery = ''
        @filter = 'open'
        @subgroups = 'mine'

        @filter = @$route.query.t if @$route.query.t
        @searchQuery = @$route.query.q if @$route.query.q
        @subgroups = @$route.query.subgroups if @$route.query.subgroups

        @refresh()

    searchQuery: debounce (val, old)->
      @$router.replace(query: {q: val})
    ,
      200

  computed:
    groupTags: ->
      @group && @group.parentOrSelf().tagNames || []
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

    unreadCount: ->
      filter(@discussions, (discussion) -> discussion.isUnread()).length


</script>

<template lang="pug">
div.discussions-panel(:key="group.id")
  trial-banner(:group="group")
  //- formatted-text(v-if="group" :model="group" column="description")
  document-list(:model='group')
  attachment-list(:attachments="group.attachments")
  v-layout.py-3(align-center)
    v-menu
      template(v-slot:activator="{ on }")
        v-btn.mr-2.text-lowercase(v-on="on" text)
          span(v-t="{path: filterName(filter), args: {count: unreadCount}}")
          v-icon mdi-menu-down
      v-list
        v-list-item(:to="{query: {t: null}}")
          v-list-item-title(v-t="'discussions_panel.open'")
        v-list-item(:to="{query: {t: 'closed'}}")
          v-list-item-title(v-t="'discussions_panel.closed'")
        v-list-item(:to="{query: {t: 'unread'}}")
          v-list-item-title(v-t="{path: 'discussions_panel.unread', args: { count: unreadCount }}")
        v-list-item(:to="{query: {t: 'subscribed'}}")
          v-list-item-title(v-t="'change_volume_form.simple.loud'")

    v-menu
      template(v-slot:activator="{ on }")
        v-btn.mr-2.text-lowercase(v-on="on" text)
            | All tags
            v-icon mdi-menu-down
      v-list
        v-list-item(v-for="tag in groupTags" :key="tag" :to="{query: {t: tag}}")
          v-list-item-title {{tag}}
    v-text-field.mr-2(clearable solo hide-details v-model="searchQuery" :placeholder="$t('navbar.search_threads', {name: group.name})" append-icon="mdi-magnify")
    v-btn.discussions-panel__new-thread-button(@click='openStartDiscussionModal(group)' color='primary' v-if='canStartThread' v-t="'navbar.start_thread'")

  v-card.discussions-panel(outlined)
    .discussions-panel__content(v-if="!searchQuery")
      .discussions-panel__list--empty(v-if='noThreads' :value="true")
        p.text-center(v-if='canViewPrivateContent' v-t="'group_page.no_threads_here'")
        p.text-center(v-if='!canViewPrivateContent' v-t="'group_page.private_threads'")
      .discussions-panel__list.thread-preview-collection__container(v-if="discussions.length")
        v-list.thread-previews(two-line)
          thread-preview(:show-group-name="groupIds.length > 1" v-for="thread in discussions" :key="thread.id" :thread="thread" group-page)

        v-layout(justify-center)
          v-btn.my-2.discussions-panel__show-more(outlined color='accent' v-if="!loader.exhausted" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")

        .lmo-hint-text.discussions-panel__no-more-threads.text-center.pa-1(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')

    .discussions-panel__content(v-if="searchQuery")
      v-alert.text-center.discussions-panel__list--empty(v-if='!searchResults.length && !searchLoader.loading')
        p(v-t="{path: 'discussions_panel.no_results_found', args: {search: searchQuery}}")
      thread-search-result(v-for="result in searchResults" :key="result.id" :result="result")
</template>

<style lang="sass">
.overflow-x-auto
  overflow-x: auto
</style>
