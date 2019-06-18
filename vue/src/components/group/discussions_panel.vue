<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import DiscussionModalMixin     from '@/mixins/discussion_modal'
import { applyLoadingFunction } from '@/shared/helpers/apply'
import { map, debounce, orderBy } from 'lodash'
import Session from '@/shared/services/session'
import WatchRecords from '@/mixins/watch_records'
import UrlFor       from '@/mixins/url_for'

export default
  mixins: [DiscussionModalMixin, WatchRecords, UrlFor]

  created: -> @init()

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    discussions: []
    searchResults: []
    loader: null
    showClosed: false
    showUnread: false
    fragment: ''
    tags: []
    includeSubgroups: false

  methods:
    init: ->
      @loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: @group.id

      @searchLoader = new RecordLoader
        collection: 'searchResults'
        params:
          group_id: @group.id

      @fetch()

      @watchRecords
        key: @group.id
        collections: ['discussions', 'groups']
        query: (store) => @query(store)

      # @maxDiscussions = if AbilityService.canViewPrivateContent(@group)
      #   @group.discussionsCount
      # else
      #   @group.publicDiscussionsCount

    query: (store) ->
      if @fragment
        chain = Records.searchResults.collection.chain()
        chain = chain.find(resultGroupId: {$in: @groupIds})
        @tags.forEach (tag) ->
          chain = chain.find({tags: {'$contains': tag}})
        chain = chain.find(query: @fragment).data()

        @searchResults = orderBy(chain, 'rank', 'desc')
      else
        chain = Records.discussions.collection.chain()

        chain = chain.find(groupId: {$in: @groupIds})

        # chain = chain.find({'tags': {'$contains': 'ya' }})

        @tags.forEach (tag) ->
          chain = chain.find({tags: {'$contains': tag}})

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
    fragment: ->
      @from = 0
      @fetch()
      @query()

    showUnread: ->
      @from = 0
      @fetch()
      @query()

    showClosed: ->
      @from = 0
      @fetch()
      @query()

    includeSubgroups: ->
      @from = 0
      @fetch()
      @query()

    group: (a, b) ->
      @init() if a.id != b.id

    isLoggedIn: -> @fetch()

    tags: ->
      @from = 0
      @fetch()
      @query()

  computed:
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
  v-toolbar(flat)
    //- v-toolbar-items
    v-text-field(solo flat append-icon="mdi-magnify" v-model="fragment" :label="$t('common.action.search')" clearable)
    v-switch.discussions-panel__toggle-closed(v-model="showClosed" :label="$t('discussions_panel.closed')")
    v-switch.discussions-panel__toggle-include-subgroups(v-if="group.hasSubgroups()" v-model="includeSubgroups" :label="$t('discussions_panel.include_subgroups')")
    v-switch(v-model="showUnread" :label="$t('discussions_panel.unread')")
    v-spacer
    v-combobox(v-model='tags' :items='groupTags' :label='$t("loomio_tags.tags")' item-text="name" multiple solo chips)
    v-btn.discussions-panel__new-thread-button(@click= 'openStartDiscussionModal(group)' outline color='primary' v-if='canStartThread' v-t="'navbar.start_thread'")

  v-progress-linear(indeterminate :active="loading")

  .discussions-panel__content(v-if="!fragment")
    .discussions-panel__list--empty(v-if='noThreads' :value="true")
      p.text-xs-center(v-t="'group_page.no_threads_here'")
      p.text-xs-center(v-if='!canViewPrivateContent', v-t="'group_page.private_threads'")
    .discussions-panel__list(v-if="discussions.length")
      section.thread-preview-collection__container
        thread-preview-collection(:threads='discussions', :limit='loader.numRequested')
      v-btn.discussions-panel__show-more(v-if="!loader.exhausted" :disabled="loader.loading" @click='loader.loadMore()', v-t="{ path: 'common.action.show_more' }")
      .lmo-hint-text.discussions-panel__no-more-threads(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')

  .discussions-panel__content(v-if="fragment")
    v-alert.discussions-panel__list--empty(v-if='!searchResults.length' :value="true" color="info" icon="info")
      p(v-t="'group_page.no_threads_here'")
    v-list(two-line v-for="result in searchResults" :key="result.id")
      v-list-tile.thread-preview.thread-preview__link(:to="urlFor(result)")
        v-list-tile-content
          v-list-tile-title {{result.title}}
          v-list-tile-sub-title
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
