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
    filter: @$route.params.filter or 'show_opened'
    pinned: []
    discussions: []
    loader: null
    searchOpen: false
    searched: {}
    fragment: ''
    discussionStartIsOpen: false

  methods:
    init: ->
      @loader = new RecordLoader
        collection: 'discussions'
        params:
          group_id: @group.id
          filter: @filter

      @loader.fetchRecords()

      # EventBus.$on this, 'subgroupsLoaded', -> @init(@filter)
      # applyLoadingFunction(this, 'searchThreads')

      @watchRecords
        key: @group.id
        collections: ['discussions', 'groups']
        query: (store) =>
          @pinned = ThreadFilter(Records, {group: @group, filters: ['show_pinned', @filter]})
          @discussions = ThreadFilter(store, {group: @group, filters: ['hide_pinned', @filter]})

    loading: ->
      @loader.loadingFirst || @searchThreadsExecuting

    searchThreads: throttle ->
      return Promise.resolve(true) unless @fragment.length
      Records.discussions.search(@group.key, @fragment).then (data) =>
        @searched = Object.assign {}, @searched, ThreadQueryService.queryFor
          name: "group_#{@group.key}_searched"
          group: @group
          ids: map(data.discussions, 'id')
          overwrite: true
    , 250

    newDiscussion: ->
      Records.discussions.build(groupId: @group.id)

    openSearch: ->
      @searchOpen = true

    closeSearch: ->
      @fragment = ''
      @searchOpen = false

    setFilter: (newFilter) ->
      @filter = newFilter
      @init()

    closeDiscussionStart: ->
      @discussionStartIsOpen = false

  watch:
    group: (a, b) ->
      @init() if a.id != b.id

    searchOpen: ->
      if @searchOpen
        this.$nextTick -> document.querySelector('.discussions-panel__search--open input').focus()

    isLoggedIn: ->
      console.log 'change in login status'
      @loader.fetchRecords()

  computed:
    noThreads: ->
      return false if @loading
      if @fragment.length
        @searched.length == 0
      else
        (@discussions.length + @pinned.length) == 0

    canViewPrivateContent: ->
      AbilityService.canViewPrivateContent(@group)

    canStartThread: ->
      AbilityService.canStartThread(@group)

    isLoggedIn: ->
      Session.isSignedIn()

</script>

<template lang="pug">
v-card.discussions-panel(flat)
  .discussions-panel__header
    h3#threads-card-title.discussions-panel__title.lmo-card-heading(v-if='!searchOpen')
      span(v-if="filter == 'show_opened'", v-t="{ path: 'group_page.open_discussions' }")
      span(v-if="filter == 'show_closed'", v-t="{ path: 'group_page.closed_discussions' }")
    .discussions-panel__search.discussions-panel__search--open.md-block.md-no-errors(v-if='searchOpen')
      i.mdi.mdi-close.md-button--tiny.lmo-pointer(@click='closeSearch')
      input(v-model='fragment', :placeholder="$t('group_page.search_threads')", @input='searchThreads')
    button.md-button--tiny(v-if='!searchOpen', @click='openSearch')
      i.mdi.mdi-magnify
    .lmo-flex__grow
    .discussions-panel__filter.discussions-panel__filter--open.lmo-link.lmo-pointer(v-if="!searchOpen && filter == 'show_closed'", @click="setFilter('show_opened')", v-t="{ path: 'group_page.show_opened', args: { count: group.openDiscussionsCount } }")
    .discussions-panel__filter.discussions-panel__filter--closed.lmo-link.lmo-pointer(v-if="!searchOpen && filter == 'show_opened' && group.closedDiscussionsCount > 0", @click="setFilter('show_closed')", v-t="{ path: 'group_page.show_closed', args: { count: group.closedDiscussionsCount } }")
    v-btn.discussions-panel__new-thread-button(@click= 'openStartDiscussionModal(group)', flat='', color='primary', v-if='canStartThread' :title="$t('navbar.start_thread')", v-t="{ path: 'navbar.start_thread' }")
  .discussions-panel__content
    .discussions-panel__list--empty(v-if='noThreads')
      p.lmo-hint-text(v-t="{ path: 'group_page.no_threads_here' }")
      p.lmo-hint-text(v-if='!canViewPrivateContent', v-t="{ path: 'group_page.private_threads' }")
    .discussions-panel__list(v-if='fragment.length == 0')
      section.thread-preview-collection__container(v-if='discussions.length || pinned.length')
        thread-preview-collection.thread-previews-container--pinned(v-if='pinned.length', :threads='pinned', :limit='loader.numRequested', order='title')
        thread-preview-collection.thread-previews-container--unpinned(v-if='discussions.length', :threads='discussions', :limit='loader.numRequested')
      .lmo-show-more(v-if='!loader.exhausted && !loader.loadingMore')
        v-btn.discussions-panel__show-more(v-show='!loading()', @click='loader.loadMore', v-t="{ path: 'common.action.show_more' }")
      .lmo-hint-text.discussions-panel__no-more-threads(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')
      loading(v-if='loader.loadingMore')
    .discussions-panel__list(v-if='fragment.length')
      section.thread-preview-collection__container(v-if='searched.length')
        thread-preview-collection.thread-previews-container--searched(:threads='searched')
    loading(v-show='loading()')
</template>

<style lang="scss">
@import 'app.scss';

.discussions-panel__header{
  padding: $cardPaddingSize $cardPaddingSize 0 $cardPaddingSize;
  display: flex;
  justify-content: space-between;
}

.discussions-panel__title {
  line-height: 36px;
}

.discussions-panel__filter {
  text-decoration: none;
  font-size: 16px;
  line-height: 36px;
  &--selected { font-weight: bold; }
}

.discussions-panel__search {
  margin: 0;
  display: flex;
  width: 0;
  flex-shrink: $z-extreme;
  transition: width 0.25s ease-in-out;
  &--open { width: 100%; }
  i {
    position: absolute;
    font-size: 20px;
    top: 0;
    right: 0;
  }
}

.discussions-panel__no-more-threads {
  padding: $cardPaddingSize;
  text-align: center;
}

.discussions-panel__dropdown {
  margin: 0 0 10px 0;
}

.discussions-panel__new-thread-button{
  @include cardButton;
}

.discussions-panel__list--empty {
  text-align: center;
  padding: 0 $cardPaddingSize $cardPaddingSize $cardPaddingSize;
}

.discussions-panel__show-more {
  @include cardMinorAction;
  @include lmoBtnLink;
}
</style>
