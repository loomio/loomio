<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import GroupModalMixin    from '@/mixins/group_modal.coffee'
import { capitalize, take, keys, every, orderBy } from 'lodash'
import WatchRecords from '@/mixins/watch_records'
import { subDays, addDays, subWeeks, subMonths } from 'date-fns'

export default
  mixins: [GroupModalMixin, WatchRecords]

  data: ->
    dashboardLoaded: Records.discussions.collection.data.length > 0
    filter: @$route.params.filter || 'hide_muted'
    views:
      proposals: []
      today: []
      yesterday: []
      thisweek: []
      thismonth: []
      older: []
    loader: null
    searchLoader: null
    searchQuery: @$route.query.q || ''
    searchResults: []

  created: ->
    @init()
    EventBus.$on 'signedIn', => @init()

  mounted: ->
    EventBus.$emit 'currentComponent',
      titleKey: @titleKey
      page: 'dashboardPage'
      search:
        placeholder: @$t('navbar.search_all_threads')

  watch:
    '$route.query': (query) ->
      @searchQuery = ''
      @searchQuery = @$route.query.q if @$route.query.q
      @dashboardLoading = false
      @refresh()

  methods:
    init: ->
      @loader = new RecordLoader
        collection: 'discussions'
        path: 'dashboard'
        params:
          filter: @filter
          per: 50

      @searchLoader = new RecordLoader
        collection: 'searchResults'

      @watchRecords
        key: 'dashboard'
        collections: ['discussions', 'searchResults']
        query: @query

      @refresh()

    refresh: ->
      @fetch()
      @query()

    fetch: ->
      return unless @loader
      if @searchQuery
        @searchLoader.fetchRecords(q: @searchQuery).then =>
          @dashboardLoaded = true
          @query()
      else
        @loader.fetchRecords().then => @dashboardLoaded = true

    query: ->
      if @searchQuery.length
        chain = Records.searchResults.collection.chain()
        chain = chain.find(query: @searchQuery).data()
        @searchResults = orderBy(chain, 'rank', 'desc')
      else
        now = new Date()
        @views.proposals = ThreadFilter(Records, filters: @filters('show_proposals'))
        @views.today     = ThreadFilter(Records, filters: @filters('hide_proposals'), from: subDays(now, 1), to: addDays(now, 10000))
        @views.yesterday = ThreadFilter(Records, filters: @filters('hide_proposals'), from: subDays(now, 2), to: subDays(now, 1))
        @views.thisweek  = ThreadFilter(Records, filters: @filters('hide_proposals'), from: subWeeks(now, 1), to: subDays(now, 2))
        @views.thismonth = ThreadFilter(Records, filters: @filters('hide_proposals'), from: subMonths(now, 1),  to: subWeeks(now, 1))
        @views.older     = ThreadFilter(Records, filters: @filters('hide_proposals'), from: subMonths(now, 6),  to: subMonths(now, 1))



    viewName: (name) ->
      if @filter == 'show_muted'
        "dashboard#{capitalize(name)}Muted"
      else
        "dashboard#{capitalize(name)}"

    filters: (filters) ->
      ['only_threads_in_my_groups', 'show_opened', @filter].concat(filters)

  computed:
    titleKey: ->
      if @filter == 'show_muted'
        'dashboard_page.filtering.muted'
      else
        'dashboard_page.filtering.all'

    viewNames: -> keys(@views)
    loadingViewNames: -> take @viewNames, 3
    noGroups: -> !Session.user().hasAnyGroups()
    promptStart: ->
      @noGroups && AbilityService.canStartGroups()
    noThreads: -> every @views, (view) => view.length == 0
    userHasMuted: -> Session.user().hasExperienced("mutingThread")
    showLargeImage: -> true

</script>

<template lang="pug">
v-container.dashboard-page.max-width-1024
  //- h1.lmo-h1-medium.dashboard-page__heading(v-t="'dashboard_page.filtering.all'")
  //- h1.lmo-h1-medium.dashboard-page__heading(v-t="'dashboard_page.filtering.all'" v-show="filter == 'hide_muted'")
  //- h1.lmo-h1-medium.dashboard-page__heading(v-t="'dashboard_page.filtering.muted'", v-show="filter == 'show_muted'")
  v-card.mb-3(v-if='!dashboardLoaded', v-for='(viewName, index) in loadingViewNames', :key='index', :class="'dashboard-page__loading dashboard-page__' + viewName", aria-hidden='true')
    v-list(two-line)
      v-subheader(v-t="'dashboard_page.threads_from.' + viewName")
      loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )
  div(v-if="dashboardLoaded")
    section.dashboard-page__loaded(v-if="searchQuery")
      v-card
        thread-search-result(v-for="result in searchResults" :key="result.id" :result="result")

    section.dashboard-page__loaded(v-if='!searchQuery')
      .dashboard-page__empty(v-if='noThreads')
        p(v-html="$t('dashboard_page.no_groups.show_all')" v-if='noGroups')
        .dashboard-page__no-threads(v-if='!noGroups')
          span(v-show="filter == 'show_all'", v-t="'dashboard_page.no_threads.show_all'")
          //- p(v-t="'dashboard_page.no_threads.show_all'")
          span(v-show="filter == 'show_muted' && userHasMuted", v-t="'dashboard_page.no_threads.show_muted'")
          router-link(to='/dashboard', v-show="filter != 'show_all' && userHasMuted")
            span(v-t="'dashboard_page.view_recent'")
      .dashboard-page__collections(v-if='!noThreads')
        v-card.mb-3(v-if='views[viewName].length', :class="'thread-preview-collection__container dashboard-page__' + viewName", v-for='viewName in viewNames' :key='viewName')
          v-subheader(v-t="'dashboard_page.threads_from.' + viewName")
          thread-preview-collection.thread-previews-container(:threads='views[viewName]')
        .dashboard-page__footer(v-if='!loader.exhausted', in-view='$inview && loader.loadMore()', in-view-options='{debounce: 200}')  
        loading(v-show='loader.loading')
</template>
<style lang="css">
.dashboard-page {
}

.dashboard-page .thread-preview__pin {
  display: none;
}

.dashboard-page__heading{
  margin: 20px 0 20px 13px;
}

.dashboard-page__date-range{
  /* @include fontSmall; */
  /* color: $grey-on-grey;
  padding: 0 $cardPaddingSize; */
}

.dashboard-page__no-threads,
.dashboard-page__no-groups,
.dashboard-page__explain-mute {
  /* margin-left: $cardPaddingSize; */
}

.dashboard-page__footer {
  height: 1px;
  position: relative;
  bottom: 200px;
}

.dashboard-page__mute-image--large {
  /* img {
    max-width: $small-max-px;
    padding: 0px 40px 0 0;
  } */
  text-align: center;
  margin: 0 0 10px;
}

.dashboard-page__mute-image--small {
  text-align: center;
  margin: 0 0 10px;
}
</style>
