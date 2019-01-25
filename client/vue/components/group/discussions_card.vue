<script lang="coffee">
Records            = require 'shared/services/records'
AbilityService     = require 'shared/services/ability_service'
EventBus           = require 'shared/services/event_bus'
RecordLoader       = require 'shared/services/record_loader'
ThreadQueryService = require 'shared/services/thread_query_service'
ModalService       = require 'shared/services/modal_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

# import { isEmpty } from 'lodash'
_isEmpty = require 'lodash/isempty'
_map = require 'lodash/map'
_throttle = require 'lodash/throttle'

module.exports =
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

<template>
  <v-card
    aria-labelledby="threads-card-title"
    class="discussions-card mb-2"
    v-if="discussions"
  >
    <div class="discussions-card__header">
        <h3
          v-if="!searchOpen"
          class="discussions-card__title lmo-card-heading"
          id="threads-card-title"
        >
          <span
            v-if="filter == 'show_opened'"
            v-t="{ path: 'group_page.open_discussions' }"
          ></span>
          <span
            v-if="filter == 'show_closed'"
            v-t="{ path: 'group_page.closed_discussions' }"
          ></span>
        </h3>
        <div
          v-if="searchOpen"
          class="discussions-card__search discussions-card__search--open md-block md-no-errors"
        >
          <i
            @click="closeSearch"
            class="mdi mdi-close md-button--tiny lmo-pointer"
          ></i>
          <input
            v-model="fragment"
            :placeholder="$t('group_page.search_threads')"
            @input="searchThreads"
          >
        </div>
        <button
          v-if="!searchOpen"
          @click="openSearch"
          class="md-button--tiny"
        >
          <i class="mdi mdi-magnify"></i>
        </button>
        <div class="lmo-flex__grow"></div>
        <div
          v-if="!searchOpen && filter == 'show_closed'"
          @click="setFilter('show_opened')"
          v-t="{ path: 'group_page.show_opened', args: { count: group.openDiscussionsCount } }"
          class="discussions-card__filter discussions-card__filter--open lmo-link lmo-pointer"
        ></div>
        <div
          v-if="!searchOpen && filter == 'show_opened' && group.closedDiscussionsCount > 0"
          @click="setFilter('show_closed')"
          v-t="{ path: 'group_page.show_closed', args: { count: group.closedDiscussionsCount } }"
          class="discussions-card__filter discussions-card__filter--closed lmo-link lmo-pointer"
        ></div>

        <v-dialog v-model="discussionStartIsOpen" lazy>
          <v-btn
            flat
            color="primary"
            v-if="canStartThread"
            slot="activator"
            :title="$t('navbar.start_thread')"
            class="discussions-card__new-thread-button"
            v-t="{ path: 'navbar.start_thread' }"
          ></v-btn>
          <discussion-start
            :discussion="newDiscussion()"
            :close="closeDiscussionStart">
          </discussion-start>
        </v-dialog>
    </div>
    <div class="discussions-card__content">
        <div v-if="noThreads" class="discussions-card__list--empty">
            <p v-t="{ path: 'group_page.no_threads_here' }" class="lmo-hint-text"></p>
            <p
              v-if="!canViewPrivateContent"
              v-t="{ path: 'group_page.private_threads' }"
              class="lmo-hint-text"
            ></p>
        </div>
        <div v-if="isEmpty(fragment)" class="discussions-card__list">
            <section
              v-if="discussions.any() || pinned.any()"
              class="thread-preview-collection__container"
            >
              <thread-preview-collection
                v-if="pinned.any()"
                :query="pinned"
                :limit="loader.numRequested"
                order="title"
                class="thread-previews-container--pinned"
              ></thread-preview-collection>
              <thread-preview-collection
                v-if="discussions.any()"
                :query="discussions"
                :limit="loader.numRequested"
                class="thread-previews-container--unpinned"
              >
              </thread-preview-collection>
            </section>
            <div v-if="!loader.exhausted && !loader.loadingMore" class="lmo-show-more">
              <button v-show="!loading"
                @click="loader.loadMore"
                v-t="{ path: 'common.action.show_more' }"
                class="discussions-card__show-more"
              ></button>
            </div>
            <div
              v-t="{ path: 'group_page.no_more_threads' }"
              v-if="loader.numLoaded > 0 && loader.exhausted"
              class="lmo-hint-text discussions-card__no-more-threads"
            ></div>
            <loading
              v-if="loader.loadingMore"
            ></loading>
        </div>
        <div
          v-if="!isEmpty(fragment)"
          class="discussions-card__list"
        >
          <section
            v-if="!isEmpty(searched) && searched.any()"
            class="thread-preview-collection__container"
          >
            <thread-preview-collection
              :query="searched"
              class="thread-previews-container--searched"
            ></thread-preview-collection>
          </section>
        </div>
        <loading
          v-show="loading"
        ></loading>
    </div>
  </v-card>
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
