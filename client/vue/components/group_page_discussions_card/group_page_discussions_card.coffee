Records            = require 'shared/services/records'
AbilityService     = require 'shared/services/ability_service'
EventBus           = require 'shared/services/event_bus'
RecordLoader       = require 'shared/services/record_loader'
ThreadQueryService = require 'shared/services/thread_query_service'
ModalService       = require 'shared/services/modal_service'
LmoUrlService      = require 'shared/services/lmo_url_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

module.exports = Vue.component 'GroupPageDiscussionsCard',
  props:
    group: Object
  mounted: ->
    @loader.fetchRecords()
    # EventBus.listen this, 'subgroupsLoaded', -> @init(@filter)
    applyLoadingFunction(this, 'searchThreads')
  data: ->
    filter: LmoUrlService.params().filter or 'show_opened'
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
    fragment: null
  methods:
    searchThreads: -> # should this be computed? async work
      return Promise.resolve(true) unless @fragment
      Records.discussions.search(@group.key, @fragment, per: 10).then (data) ->
        @searched = ThreadQueryService.queryFor
          name: "group_#{@group.key}_searched"
          group: @group
          ids: _.map(data.discussions, 'id')
          overwrite: true
    startDiscussion: ->
      ModalService.open 'DiscussionStartModal', discussion: -> Records.discussions.build(groupId: @group.id)
    openSearch: ->
      @searchOpen = true
      $timeout -> document.querySelector('.discussions-card__search input').focus()
    closeSearch: ->
      @fragment = null
      @searchOpen = false

  computed:
    loading: ->
      @loader.loadingFirst || @searchThreadsExecuting
    isEmpty: ->
      return if @loading
      if @fragment
        !@searched || !@searched.any()
      else
        !@discussions.any() && !@pinned.any()
    canViewPrivateContent: ->
      AbilityService.canViewPrivateContent(@group)
    canStartThread: ->
      AbilityService.canStartThread(@group)

  template: """
  <section
    aria-labelledby="threads-card-title"
    class="discussions-card lmo-card--no-padding"
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
            translate="group_page.open_discussions"
          ></span>
          <span
            v-if="filter == 'show_closed'"
            translate="group_page.closed_discussions"
          ></span>
        </h3>
        <div
          :class="{'discussions-card__search--open': searchOpen}"
          class="discussions-card__search md-block md-no-errors"
        >
          <i
            @click="closeSearch"
            v-if="searchOpen"
            class="mdi mdi-close md-button--tiny lmo-pointer"
          ></i>
          <input
            v-model="fragment"
            :placeholder="$t('group_page.search_threads')"
            @change="searchThreads"
            <!-- v-model-options="{debounce: 250}" -->
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
          @click="init('show_opened')"
          v-t="{ path: 'group_page.show_opened', args: { count: group.openDiscussionsCount } }"
          class="discussions-card__filter discussions-card__filter--open lmo-link lmo-pointer"
        ></div>
        <div
          v-if="!searchOpen && filter == 'show_opened' && group.closedDiscussionsCount > 0"
          @click="init('show_closed')"
          v-t="{ path: 'group_page.show_closed', args: { count: group.closedDiscussionsCount } }"
          class="discussions-card__filter discussions-card__filter--closed lmo-link lmo-pointer"
        ></div>
        <button
          v-if="canStartThread"
          @click="startDiscussion"
          :title="$t('navbar.start_thread')"
          class="md-primary md-raised discussions-card__new-thread-button"
        >
          <span translate="navbar.start_thread"></span>
        </button>
    </div>
    <div class="discussions-card__content">
        <div v-if="isEmpty" class="discussions-card__list--empty">
            <p translate="group_page.no_threads_here" class="lmo-hint-text"></p>
            <p
              v-if="!canViewPrivateContent"
              translate="group_page.private_threads"
              class="lmo-hint-text"
            ></p>
        </div>
        <div v-if="!fragment" class="discussions-card__list">
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
                translate="common.action.show_more"
                class="discussions-card__show-more"
              ></button>
            </div>
            <div
              translate="group_page.no_more_threads"
              v-if="loader.numLoaded > 0 && loader.exhausted"
              class="lmo-hint-text discussions-card__no-more-threads"
            ></div>
            <!-- <loading
              v-if="loader.loadingMore"
            ></loading> -->
        </div>
        <div
          v-if="fragment"
          class="discussions-card__list"
        >
          <section
            v-if="searched.any()"
            class="thread-preview-collection__container"
          >
            <thread-preview-collection
              :query="searched"
              class="thread-previews-container--searched"
            ></thread-preview-collection>
          </section>
        </div>
        <!-- <loading
          v-show="loading"
        ></loading> -->
    </div>
</section>
"""
