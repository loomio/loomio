<script lang="coffee">
import AppConfig          from '@/shared/services/app_config'
import Records            from '@/shared/services/records'
import Session            from '@/shared/services/session'
import EventBus           from '@/shared/services/event_bus'
import AbilityService     from '@/shared/services/ability_service'
import RecordLoader       from '@/shared/services/record_loader'
import ThreadQueryService from '@/shared/services/thread_query_service'
import GroupModalMixin from '@/mixins/group_modal.coffee'
import { capitalize, take, keys, every } from 'lodash'

export default
  mixins: [GroupModalMixin]
  data: ->
    dashboardLoaded: Records.discussions.collection.data.length > 0
    filter: @$route.params.filter || 'hide_muted'
    views:
      proposals: ThreadQueryService.queryFor
        name:    @viewName("proposals")
        filters: @filters('show_proposals')
      today:     ThreadQueryService.queryFor
        name:    @viewName("today")
        from:    '1 second ago'
        to:      '-10 year ago' # into the future!
        filters: @filters('hide_proposals')
      yesterday: ThreadQueryService.queryFor
        name:    @viewName("yesterday")
        from:    '1 day ago'
        to:      '1 second ago'
        filters: @filters('hide_proposals')
      thisweek: ThreadQueryService.queryFor
        name:    @viewName("thisWeek")
        from:    '1 week ago'
        to:      '1 day ago'
        filters: @filters('hide_proposals')
      thismonth: ThreadQueryService.queryFor
        name:    @viewName("thisMonth")
        from:    '1 month ago'
        to:      '1 week ago'
        filters: @filters('hide_proposals')
      older: ThreadQueryService.queryFor
        name:    @viewName("older")
        from:    '3 month ago'
        to:      '1 month ago'
        filters: @filters('hide_proposals')
    loader: new RecordLoader
      collection: 'discussions'
      path: 'dashboard'
      params:
        filter: @filter
        per: 50
  mounted: ->
    EventBus.$emit 'currentComponent',
      titleKey: @titleKey
      page: 'dashboardPage'
      # filter: $routeParams.filter
    @loader.fetchRecords().then => @dashboardLoaded = true
    @openStartGroupModal if @noGroups && @canStartGroup()
  methods:
    viewName: (name) ->
      if @filter == 'show_muted'
        "dashboard#{capitalize(name)}Muted"
      else
        "dashboard#{capitalize(name)}"

    filters: (filters) ->
      ['only_threads_in_my_groups', 'show_opened', @filter].concat(filters)
  computed:
    titleKey: ->
      # if @filter == 'show_muted'
      #   'dashboard_page.filtering.muted'
      # else
      'dashboard_page.filtering.all'

    viewNames: -> keys(@views)
    loadingViewNames: -> take @viewNames, 3
    noGroups: -> !Session.user().hasAnyGroups()
    promptStart: -> !Session.user().hasAnyGroups() && AbilityService.canStartGroups()
    noThreads: -> every @views, (view) => !view.any()
    userHasMuted: -> Session.user().hasExperienced("mutingThread")
    showLargeImage: -> true

</script>

<template lang="pug">
v-container.lmo-main-container.dashboard-page
  h1.lmo-h1-medium.dashboard-page__heading(v-t="'dashboard_page.filtering.all'")
  //- h1.lmo-h1-medium.dashboard-page__heading(v-t="'dashboard_page.filtering.all'" v-show="filter == 'hide_muted'")
  //- h1.lmo-h1-medium.dashboard-page__heading(v-t="'dashboard_page.filtering.muted'", v-show="filter == 'show_muted'")
  section(v-if='!dashboardLoaded', v-for='(viewName, index) in loadingViewNames', :key='index', :class="'dashboard-page__loading dashboard-page__' + viewName", aria-hidden='true')
    h2.dashboard-page__date-range(v-t="'dashboard_page.threads_from.' + viewName")
    .thread-previews-container
      // <loading_content line-count="2" ng-repeat="i in [1,2] track by $index" class="thread-preview"></loading_content>
  section.dashboard-page__loaded(v-if='dashboardLoaded')
    .dashboard-page__empty(v-if='noThreads')
      p(v-t="'dashboard_page.no_groups.show_all'", v-if='noGroups')
      .dashboard-page__no-threads(v-if='!noGroups')
        span(v-show="filter == 'show_all'", v-t="'dashboard_page.no_threads.show_all'")
        p(v-t="'dashboard_page.no_threads.show_all'")
        span(v-show="filter == 'show_muted' && userHasMuted", v-t="'dashboard_page.no_threads.show_muted'")
        router-link(to='/dashboard', v-show="filter != 'show_all' && userHasMuted")
          span(v-t="'dashboard_page.view_recent'")
      .dashboard-page__explain-mute(v-if="filter == 'show_muted' && !userHasMuted")
        p
          strong(v-t="'dashboard_page.explain_mute.title'")
        p(v-t="'dashboard_page.explain_mute.explanation_html'")
        p(v-t="'dashboard_page.explain_mute.instructions'")
        .dashboard-page__mute-image--large(v-if='showLargeImage')
          img(src='/img/mute.png')
        .dashboard-page__mute-image--small(v-if='!showLargeImage')
          img(src='/img/mute-small.png')
        p(v-t="'dashboard_page.explain_mute.see_muted_html'")
    .dashboard-page__collections(v-if='!noThreads')
      v-card.mb-3(v-if='views[viewName].any()', :class="'thread-preview-collection__container dashboard-page__' + viewName", v-for='viewName in viewNames' :key='viewName')
        v-subheader(v-t="'dashboard_page.threads_from.' + viewName")
        thread-preview-collection.thread-previews-container(:query='views[viewName]')
      .dashboard-page__footer(v-if='!loader.exhausted', in-view='$inview && loader.loadMore()', in-view-options='{debounce: 200}')  
      loading(v-show='loader.loading')
</template>
<style lang="scss">
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
  img {
    /* max-width: $small-max-px; */
    padding: 0px 40px 0 0;
  }
  text-align: center;
  margin: 0 0 10px;
}

.dashboard-page__mute-image--small {
  text-align: center;
  margin: 0 0 10px;
}
</style>
