<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import DiscussionModalMixin     from '@/mixins/discussion_modal'
import { applyLoadingFunction } from '@/shared/helpers/apply'
import { map, throttle } from 'lodash'
import Session from '@/shared/services/session'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [DiscussionModalMixin, WatchRecords]

  created: -> @init()

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    discussions: []
    loader: null
    showClosed: false
    fragment: ''
    includeSubgroups: false

  methods:
    init: ->
      @loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: @group.id

      @fetch()

      # EventBus.$on this, 'subgroupsLoaded', -> @init(@filter)
      # applyLoadingFunction(this, 'searchThreads')

      @watchRecords
        key: @group.id
        collections: ['discussions', 'groups']
        query: (store) => @query(store)

      # @maxDiscussions = if AbilityService.canViewPrivateContent(@group)
      #   @group.discussionsCount
      # else
      #   @group.publicDiscussionsCount

    query: (store) ->
      chain = Records.discussions.collection.chain()

      if @includeSubgroups
        chain = chain.find(groupId: {$in: @group.organisationIds()})
      else
        chain = chain.find(groupId: @group.id)

      if @showClosed
        chain = chain.find(closedAt: {$ne: null})
      else
        chain = chain.find(closedAt: null)

      chain = chain.compoundsort([['pinned', true], ['lastActivityAt', true]])

      @discussions = chain.data()


    fetch: ->
      params = {from: @from}
      params.filter = 'show_closed' if @showClosed
      params.include_subgroups = @includeSubgroups

      @loader.fetchRecords(params)


    searchThreads: throttle ->
      return Promise.resolve(true) unless @fragment.length
      Records.discussions.search(@group.key, @fragment).then (data) =>
        @searched = Object.assign {}, @searched, ThreadFilter.queryFor
          name: "group_#{@group.key}_searched"
          group: @group
          ids: map(data.discussions, 'id')
          overwrite: true
    , 250

  watch:
    showClosed: ->
      @fetch()
      @query()

    includeSubgroups: ->
      @fetch()
      @query()

    group: (a, b) ->
      @init() if a.id != b.id

    searchOpen: ->
      if @searchOpen
        this.$nextTick -> document.querySelector('.discussions-panel__search--open input').focus()

    isLoggedIn: -> @fetch()

  computed:
    noThreads: ->
      !@loading && @discussions.length == 0

    canViewPrivateContent: ->
      AbilityService.canViewPrivateContent(@group)

    canStartThread: ->
      AbilityService.canStartThread(@group)

    isLoggedIn: ->
      Session.isSignedIn()

</script>

<template lang="pug">
.discussions-panel
  v-toolbar(flat dense)
    //- v-toolbar-items
    v-toolbar-items
      v-text-field(solo append-icon="mdi-magnify" v-model="fragment" :placeholder="$t('group_page.search_threads')", @change='fetch')
      v-switch(v-model="showClosed" :label="$t('discussions_panel.closed')")
      v-switch(v-model="includeSubgroups" :label="$t('discussions_panel.include_subgroups')")
    v-spacer
    v-btn.discussions-panel__new-thread-button(@click= 'openStartDiscussionModal(group)' outline color='primary' v-if='canStartThread' v-t="'navbar.start_thread'")

  v-progress-linear(indeterminate :active="loader.loading")
  .discussions-panel__content
    .discussions-panel__list--empty(v-if='noThreads')
      p.lmo-hint-text(v-t="{ path: 'group_page.no_threads_here' }")
      p.lmo-hint-text(v-if='!canViewPrivateContent', v-t="{ path: 'group_page.private_threads' }")
    .discussions-panel__list(v-if="discussions.length")
      section.thread-preview-collection__container
        thread-preview-collection(:threads='discussions', :limit='loader.numRequested')
      v-btn.discussions-panel__show-more(v-if="!loader.exhausted" :disabled="loader.loading" @click='loader.loadMore()', v-t="{ path: 'common.action.show_more' }")
      .lmo-hint-text.discussions-panel__no-more-threads(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')
</template>
