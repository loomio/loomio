<style lang="scss">
.dashboard-page {
  /* @include lmoRow; */
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

<script lang="coffee">
AppConfig          = require 'shared/services/app_config'
Records            = require 'shared/services/records'
Session            = require 'shared/services/session'
EventBus           = require 'shared/services/event_bus'
AbilityService     = require 'shared/services/ability_service'
RecordLoader       = require 'shared/services/record_loader'
ThreadQueryService = require 'shared/services/thread_query_service'
ModalService       = require 'shared/services/modal_service'

_capitalize = require 'lodash/capitalize'
_take = require 'lodash/take'
_keys = require 'lodash/keys'
_every = require 'lodash/every'

module.exports =
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
  created: ->
    # EventBus.broadcast $rootScope, 'currentComponent',
    #   titleKey: titleKey()
    #   page: 'dashboardPage'
    #   filter: $routeParams.filter
    @loader.fetchRecords().then => @dashboardLoaded = true
    @startGroup() if @noGroups && AbilityService.canStartGroups()
  methods:
    viewName: (name) ->
      if @filter == 'show_muted'
        "dashboard#{_capitalize(name)}Muted"
      else
        "dashboard#{_capitalize(name)}"

    filters: (filters) ->
      ['only_threads_in_my_groups', 'show_opened', @filter].concat(filters)

    startGroup: -> ModalService.open 'GroupModal', group: => Records.groups.build()
  computed:
    titleKey: ->
      if @filter == 'show_muted'
        'dashboard_page.filtering.muted'
      else
        'dashboard_page.filtering.all'

    viewNames: -> _keys(@views)
    loadingViewNames: -> _take @viewNames, 3
    noGroups: -> !Session.user().hasAnyGroups()
    promptStart: -> !Session.user().hasAnyGroups() && AbilityService.canStartGroups()
    noThreads: -> _every @views, (view) => !view.any()
    userHasMuted: -> Session.user().hasExperienced("mutingThread")
    showLargeImage: -> $mdMedia("gt-sm")

</script>

<template>
  <div class="lmo-one-column-layout">
    <main class="dashboard-page lmo-row">
      <h1 v-t="'dashboard_page.filtering.all'" v-show="filter == 'hide_muted'" class="lmo-h1-medium dashboard-page__heading"></h1>
      <h1 v-t="'dashboard_page.filtering.muted'" v-show="filter == 'show_muted'" class="lmo-h1-medium dashboard-page__heading"></h1>
      <section v-if="!dashboardLoaded" v-for="(viewName, index) in loadingViewNames" :key="index" :class="'dashboard-page__loading dashboard-page__' + viewName" aria-hidden="true">
        <h2 v-t="'dashboard_page.threads_from.' + viewName" class="dashboard-page__date-range"></h2>
        <div class="thread-previews-container">
          <!-- <loading_content line-count="2" ng-repeat="i in [1,2] track by $index" class="thread-preview"></loading_content> -->
        </div>
      </section>
      <section v-if="dashboardLoaded" class="dashboard-page__loaded">
        <div v-if="noThreads" class="dashboard-page__empty">
          <p v-t="'dashboard_page.no_groups.show_all'" v-if="noGroups"></p>
          <div v-if="!noGroups" class="dashboard-page__no-threads">
            <span v-show="filter == 'show_all'" v-t="'dashboard_page.no_threads.show_all'"></span>
            <p v-t="'dashboard_page.no_threads.show_all'"></p>
            <span v-show="filter == 'show_muted' && userHasMuted" v-t="'dashboard_page.no_threads.show_muted'"></span>
            <router-link to="/dashboard" v-show="filter != 'show_all' && userHasMuted">
              <span v-t="'dashboard_page.view_recent'"></span>
            </router-link>
          </div>
          <div v-if="filter == 'show_muted' && !userHasMuted" class="dashboard-page__explain-mute">
            <p><strong v-t="'dashboard_page.explain_mute.title'"></strong></p>
            <p v-t="'dashboard_page.explain_mute.explanation_html'"></p>
            <p v-t="'dashboard_page.explain_mute.instructions'"></p>
            <div v-if="showLargeImage" class="dashboard-page__mute-image--large">
              <img src="/img/mute.png">
            </div>
            <div v-if="!showLargeImage" class="dashboard-page__mute-image--small">
              <img src="/img/mute-small.png">
            </div>
            <p v-t="'dashboard_page.explain_mute.see_muted_html'"></p>
          </div>
        </div>
        <div v-if="!noThreads" class="dashboard-page__collections">
          <section v-if="views[viewName].any()" :class="'thread-preview-collection__container dashboard-page__' + viewName" v-for="viewName in viewNames">
            <h2 v-t="'dashboard_page.threads_from.' + viewName" class="dashboard-page__date-range"></h2>
            <thread-preview-collection :query="views[viewName]" class="thread-previews-container"></thread-preview-collection>
          </section>
          <div v-if="!loader.exhausted" in-view="$inview && loader.loadMore()" in-view-options="{debounce: 200}" class="dashboard-page__footer">&nbsp;</div>
          <loading v-show="loader.loading"></loading>
        </div>
      </section>
    </main>
  </div>
</template>
