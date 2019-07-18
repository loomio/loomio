<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import DiscussionModalMixin     from '@/mixins/discussion_modal'
import { applyLoadingFunction } from '@/shared/helpers/apply'
import { map, debounce, orderBy, intersection, compact } from 'lodash'
import Session from '@/shared/services/session'
import WatchRecords from '@/mixins/watch_records'
import UrlFor       from '@/mixins/url_for'

export default
  mixins: [DiscussionModalMixin, WatchRecords, UrlFor]

  created: -> @init()

  data: ->
    group: null
    discussions: []
    searchResults: []
    loader: null
    fragment: ''
    filters: []
    selectedFilters: []

  methods:
    init: ->
      @group = Records.groups.fuzzyFind(@$route.params.key)
      @filters = compact [
        ({name: @$t('discussions_panel.include_subgroups'), value: 'includeSubgroups'} if @group.hasSubgroups())
        {name: @$t('discussions_panel.closed'), value: 'showClosed'}
        {name: @$t('discussions_panel.unread'), value: 'showUnread'}
      ]

      @groupTags.forEach (tag) => @filters.push({name: tag, value: tag})

      @selectedFilters.push('includeSubgroups') if @group.hasSubgroups()

      @loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: @group.id

      @searchLoader = new RecordLoader
        collection: 'searchResults'
        params:
          group_id: @group.id

      @watchRecords
        key: @group.id
        collections: ['discussions', 'groups']
        query: (store) => @query(store)

      @refresh()

    refresh: ->
      @from = 0
      @fetch()
      @query()

    query: (store) ->
      if @fragment
        chain = Records.searchResults.collection.chain()
        chain = chain.find(resultGroupId: {$in: @groupIds})

        @tags.forEach (tag) ->
          chain = chain.find({tagNames: {'$contains': tag}})

        chain = chain.find(query: @fragment).data()

        @searchResults = orderBy(chain, 'rank', 'desc')
      else
        chain = Records.discussions.collection.chain()
        chain = chain.find(groupId: {$in: @groupIds})

        @tags.forEach (tag) ->
          chain = chain.find({tagNames: {'$contains': tag}})

        if @showClosed
          chain = chain.find(closedAt: {$ne: null})
        else
          chain = chain.find(closedAt: null)

        if @showUnread
          chain = chain.where (discussion) -> discussion.isUnread()

        chain = chain.compoundsort([['pinned', true], ['lastActivityAt', true]])

        @discussions = chain.data()

    fetch: debounce ->
      if @fragment
        params = {q: @fragment}
        params.include_subgroups = @includeSubgroups
        params.tags = @tags.join("|")
        @searchLoader.fetchRecords params
      else
        params = {from: @from}
        params.filter = 'show_closed' if @showClosed
        params.include_subgroups = @includeSubgroups
        params.tags = @tags.join("|")
        @loader.fetchRecords(params)
    ,
      300

  watch:
    fragment: -> @refresh()
    selectedFilters: -> @refresh()
    isLoggedIn: -> @refresh()
    $route: (a, b) -> @init()

  computed:
    showClosed: ->
      @selectedFilters.includes('showClosed')

    showUnread: ->
      @selectedFilters.includes('showUnread')

    includeSubgroups: ->
      @selectedFilters.includes('includeSubgroups')

    tags: ->
      intersection(@selectedFilters, @groupTags)

    groupIds: ->
      if @includeSubgroups
        @group.organisationIds()
      else
        [@group.id]

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

</script>

<template lang="pug">
.discussions-panel
  v-toolbar(flat align-center)
    v-toolbar-items
      v-text-field(solo flat append-icon="mdi-magnify" v-model="fragment" :label="$t('common.action.search')" clearable)
      v-select(solo flat multiple chips deletable-chips v-model='selectedFilters' :items='filters' :label="$t('common.action.filter')" item-text="name")
    //- v-switch.discussions-panel__toggle-closed(v-model="showClosed" :label="$t('discussions_panel.closed')")
    //- v-switch.discussions-panel__toggle-include-subgroups(v-if="group.hasSubgroups()" v-model="includeSubgroups" :label="$t('discussions_panel.include_subgroups')")
    //- v-switch(v-model="showUnread" :label="$t('discussions_panel.unread')")
    v-spacer
    v-btn.discussions-panel__new-thread-button(@click= 'openStartDiscussionModal(group)' outlined color='primary' v-if='canStartThread' v-t="'navbar.start_thread'")
    v-progress-linear(color="accent" indeterminate :active="loading" absolute bottom)


  .discussions-panel__content(v-if="!fragment")
    .discussions-panel__list--empty(v-if='noThreads' :value="true")
      p.text-xs-center(v-t="'group_page.no_threads_here'")
      p.text-xs-center(v-if='!canViewPrivateContent', v-t="'group_page.private_threads'")
    .discussions-panel__list.thread-preview-collection__container(v-if="discussions.length")
      v-list.thread-previews(two-line)
        thread-preview(:show-group-name="includeSubgroups" v-for="thread in discussions" :key="thread.id" :thread="thread" group-page)
      v-btn.discussions-panel__show-more(v-if="!loader.exhausted" :disabled="loader.loading" @click='loader.loadMore()', v-t="{ path: 'common.action.show_more' }")
      .lmo-hint-text.discussions-panel__no-more-threads(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')

  .discussions-panel__content(v-if="fragment")
    v-alert.discussions-panel__list--empty(v-if='!searchResults.length' :value="true" color="info" icon="info")
      p(v-t="'group_page.no_threads_here'")
    v-list(two-line v-for="result in searchResults" :key="result.id")
      v-list-item.thread-preview.thread-preview__link(:to="urlFor(result)")
        v-list-item-content
          v-list-item-title {{result.title}}
          v-list-item-subtitle
            span(v-html="result.resultGroupName")
            | &nbsp;
            | ·
            | &nbsp;
            time-ago(:date='result.lastActivityAt')
            | &nbsp;
            | ·
            | &nbsp;
            span(v-html="result.blurb")
</template>
