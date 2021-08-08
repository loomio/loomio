<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadFilter       from '@/shared/services/thread_filter'
import { capitalize, take, keys, every, orderBy, debounce } from 'lodash'
import { subDays, addDays, subWeeks, subMonths } from 'date-fns'

export default
  data: ->
    dashboardLoaded: Records.discussions.collection.data.length > 0
    filter: @$route.params.filter || 'hide_muted'
    discussions: []
    loader: null
    searchLoader: null
    searchResults: []

  created: ->
    @onQueryInput = debounce (val) =>
      @$router.replace(@mergeQuery(q: val))
    , 1000

    @init()
    EventBus.$on 'signedIn', @init

  beforeDestroy: ->
    EventBus.$off 'signedIn', @init

  mounted: ->
    EventBus.$emit('content-title-visible', false)
    EventBus.$emit 'currentComponent',
      titleKey: 'dashboard_page.aria_label'
      page: 'dashboardPage'
      search:
        placeholder: @$t('navbar.search_all_threads')

  watch:
    '$route.query': 'refresh'

  methods:
    init: ->
      @loader = new RecordLoader
        collection: 'discussions'
        path: 'dashboard'
        params:
          exclude_types: 'group'
          filter: @filter
          per: 60

      @searchLoader = new RecordLoader
        collection: 'searchResults'

      @watchRecords
        key: 'dashboard'
        collections: ['discussions', 'searchResults', 'memberships']
        query: @query

      @refresh()

    refresh: ->
      return unless Session.isSignedIn()
      @fetch()
      @query()

    fetch: ->
      return unless @loader
      if @$route.query.q
        @searchLoader.fetchRecords(q: @$route.query.q, from: 0).then =>
          @dashboardLoaded = true
          @query()
      else
        @loader.fetchRecords().then => @dashboardLoaded = true

    query: ->
      if @$route.query.q
        chain = Records.searchResults.collection.chain()
        chain = chain.find(query: @$route.query.q).data()
        @searchResults = orderBy(chain, 'rank', 'desc')
      else
        groupIds = Records.memberships.collection.find(userId: Session.user().id).map (m) -> m.groupId
        chain = Records.discussions.collection.chain()
        chain = chain.find($or: [{groupId: {$in: groupIds}}, {discussionReaderUserId: Session.user().id, revokedAt: null}])
        chain = chain.find(discardedAt: null)
        chain = chain.find(closedAt: null)
        chain = chain.find(lastActivityAt: { $gt: subMonths(new Date(), 6) })
        @discussions = chain.simplesort('lastActivityAt', true).data()

  computed:
    noGroups: -> Session.user().groups().length == 0
    promptStart: ->
      @noGroups && AbilityService.canStartGroups()
    userHasMuted: -> Session.user().hasExperienced("mutingThread")
    showLargeImage: -> true

</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024
    h1.display-1.my-4(tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'dashboard_page.aria_label'")
    v-layout.mb-3(v-if='dashboardLoaded')
      v-text-field(clearable solo hide-details :value="$route.query.q" @input="onQueryInput" :placeholder="$t('common.action.search')" append-icon="mdi-magnify")

    dashboard-polls-panel

    v-card.mb-3(v-if='!dashboardLoaded')
      v-list(two-line)
        v-subheader(v-t="'dashboard_page.recent_threads'")
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )

    div(v-if="dashboardLoaded")
      section.dashboard-page__loaded(v-if="$route.query.q")
        v-card
          thread-search-result(v-for="result in searchResults" :key="result.id" :result="result")

      section.dashboard-page__loaded(v-if='!$route.query.q')
        .dashboard-page__empty(v-if='discussions.length == 0')
          p(v-html="$t('dashboard_page.no_groups.show_all')" v-if='noGroups')
          .dashboard-page__no-threads(v-if='!noGroups')
            span(v-show="filter == 'show_all'" v-t="'dashboard_page.no_threads.show_all'")
            //- p(v-t="'dashboard_page.no_threads.show_all'")
            span(v-show="filter == 'show_muted' && userHasMuted", v-t="'dashboard_page.no_threads.show_muted'")
            router-link(to='/dashboard', v-show="filter != 'show_all' && userHasMuted")
              span(v-t="'dashboard_page.view_recent'")
        .dashboard-page__collections(v-if='discussions.length')
          v-card.mb-3.thread-preview-collection__container.thread-previews-container
            v-list.thread-previews(two-line)
              v-subheader(v-t="'dashboard_page.recent_threads'")
              thread-preview(v-for="thread in discussions" :key="thread.id" :thread="thread")

          .dashboard-page__footer(v-if='!loader.exhausted')  
          loading(v-show='loader.loading')
</template>
<style lang="sass">
// .dashboard-page
// 	.thread-preview__pin
// 		display: none
// .dashboard-page__heading
// 	margin: 20px 0 20px 13px
// .dashboard-page__date-range
// .dashboard-page__no-threads,
// .dashboard-page__no-groups,
// .dashboard-page__explain-mute
// .dashboard-page__footer
// 	height: 1px
// 	position: relative
// 	bottom: 200px
// .dashboard-page__mute-image--large
// 	text-align: center
// 	margin: 0 0 10px
// .dashboard-page__mute-image--small
// 	text-align: center
// 	margin: 0 0 10px

</style>
