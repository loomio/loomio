<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadQueryService from '@/shared/services/thread_query_service'
import ModalService       from '@/shared/services/modal_service'
import { applyLoadingFunction } from '@/shared/helpers/apply'
import _isEmpty from 'lodash/isEmpty'
import _map from 'lodash/map'
import _throttle from 'lodash/throttle'

export default
  props:
    group: Object
  mounted: ->
    @loader.fetchRecords()
    # EventBus.listen this, 'subgroupsLoaded', -> @init(@filter)
    applyLoadingFunction(this, 'searchThreads')
  data: ->
    filter: @$route.params.filter or 'show_opened'
    pinned: ThreadQueryService.queryFor
      name: "group_#{@group.key}_pinned"
      group: @group
      filters: ['show_pinned', @filter]
      overwrite: true
    discussions: ThreadQueryService.queryFor
      name: "group_#{@group.key}_unpinned"
      group: @group
      filters: ['hide_pinned', @filter]
      overwrite: true
    loader: new RecordLoader
      collection: 'discussions'
      params:
        group_id: @group.id
        filter:   @filter
    searchOpen: false
    searched: {}
    fragment: ''
    discussionStartIsOpen: false
  methods:
    searchThreads: _throttle ->
      return Promise.resolve(true) unless !isEmpty @fragment
      Records.discussions.search(@group.key, @fragment).then (data) =>
        @searched = Object.assign {}, @searched, ThreadQueryService.queryFor
          name: "group_#{@group.key}_searched"
          group: @group
          ids: _map(data.discussions, 'id')
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
    isEmpty: (o) ->
      _isEmpty(o)

    closeDiscussionStart: ->
      @discussionStartIsOpen = false

  watch:
    searchOpen: ->
      if @searchOpen
        this.$nextTick -> document.querySelector('.discussions-card__search--open input').focus()
  computed:
    loading: ->
      @loader.loadingFirst || @searchThreadsExecuting
    noThreads: ->
      return if @loading
      if !@isEmpty @fragment
        @isEmpty @searched || !@searched.any()
      else
        !@discussions.any() && !@pinned.any()
    canViewPrivateContent: ->
      AbilityService.canViewPrivateContent(@group)
    canStartThread: ->
      AbilityService.canStartThread(@group)

</script>

<template lang="pug">
v-card.discussions-card(aria-labelledby='threads-card-title', v-if='discussions')
  .discussions-card__header
    h3#threads-card-title.discussions-card__title.lmo-card-heading(v-if='!searchOpen')
      span(v-if="filter == 'show_opened'", v-t="{ path: 'group_page.open_discussions' }")
      span(v-if="filter == 'show_closed'", v-t="{ path: 'group_page.closed_discussions' }")
    .discussions-card__search.discussions-card__search--open.md-block.md-no-errors(v-if='searchOpen')
      i.mdi.mdi-close.md-button--tiny.lmo-pointer(@click='closeSearch')
      input(v-model='fragment', :placeholder="$t('group_page.search_threads')", @input='searchThreads')
    button.md-button--tiny(v-if='!searchOpen', @click='openSearch')
      i.mdi.mdi-magnify
    .lmo-flex__grow
    .discussions-card__filter.discussions-card__filter--open.lmo-link.lmo-pointer(v-if="!searchOpen && filter == 'show_closed'", @click="setFilter('show_opened')", v-t="{ path: 'group_page.show_opened', args: { count: group.openDiscussionsCount } }")
    .discussions-card__filter.discussions-card__filter--closed.lmo-link.lmo-pointer(v-if="!searchOpen && filter == 'show_opened' && group.closedDiscussionsCount > 0", @click="setFilter('show_closed')", v-t="{ path: 'group_page.show_closed', args: { count: group.closedDiscussionsCount } }")
    v-dialog(v-model='discussionStartIsOpen', lazy='')
      v-btn.discussions-card__new-thread-button(flat='', color='primary', v-if='canStartThread', slot='activator', :title="$t('navbar.start_thread')", v-t="{ path: 'navbar.start_thread' }")
      discussion-start(:discussion='newDiscussion()', :close='closeDiscussionStart')
  .discussions-card__content
    .discussions-card__list--empty(v-if='noThreads')
      p.lmo-hint-text(v-t="{ path: 'group_page.no_threads_here' }")
      p.lmo-hint-text(v-if='!canViewPrivateContent', v-t="{ path: 'group_page.private_threads' }")
    .discussions-card__list(v-if='isEmpty(fragment)')
      section.thread-preview-collection__container(v-if='discussions.any() || pinned.any()')
        thread-preview-collection.thread-previews-container--pinned(v-if='pinned.any()', :query='pinned', :limit='loader.numRequested', order='title')
        thread-preview-collection.thread-previews-container--unpinned(v-if='discussions.any()', :query='discussions', :limit='loader.numRequested')
      .lmo-show-more(v-if='!loader.exhausted && !loader.loadingMore')
        button.discussions-card__show-more(v-show='!loading', @click='loader.loadMore', v-t="{ path: 'common.action.show_more' }")
      .lmo-hint-text.discussions-card__no-more-threads(v-t="{ path: 'group_page.no_more_threads' }", v-if='loader.numLoaded > 0 && loader.exhausted')
      loading(v-if='loader.loadingMore')
    .discussions-card__list(v-if='!isEmpty(fragment)')
      section.thread-preview-collection__container(v-if='!isEmpty(searched) && searched.any()')
        thread-preview-collection.thread-previews-container--searched(:query='searched')
    loading(v-show='loading')
</template>

<style lang="scss">
@import 'app.scss';

.discussions-card__header{
  padding: $cardPaddingSize $cardPaddingSize 0 $cardPaddingSize;
  display: flex;
  justify-content: space-between;
}

.discussions-card__title {
  line-height: 36px;
}

.discussions-card__filter {
  text-decoration: none;
  font-size: 16px;
  line-height: 36px;
  &--selected { font-weight: bold; }
}

.discussions-card__search {
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

.discussions-card__no-more-threads {
  padding: $cardPaddingSize;
  text-align: center;
}

.discussions-card__dropdown {
  margin: 0 0 10px 0;
}

.discussions-card__new-thread-button{
  @include cardButton;
}

.discussions-card__list--empty {
  text-align: center;
  padding: 0 $cardPaddingSize $cardPaddingSize $cardPaddingSize;
}

.discussions-card__show-more {
  @include cardMinorAction;
  @include lmoBtnLink;
}
</style>
