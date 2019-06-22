<style lang="scss">
// @import 'variables';
// @import 'mixins';
// @import 'lmo_card';
.explore-page {
  // @include cardPadding;
}

.explore-page__search-field {
  position: relative;
  // background-color: $background-color;
  // color: $primary-text-color;
  width: 100%;
  margin: 20px 0;
  i {
    position: absolute;
    top: 4px;
    right: 4px;
    // color: $grey-on-white;
  }
}

.explore-page__no-results-found, .explore-page__search-results {
  margin: 20px 0;
  text-align: left;
  // color: $grey-on-white;
}

.explore-page__groups {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
}

.explore-page__group-stats {
  color: #D0D0D0;
  i { color: #D0D0D0; }
}

.explore-page__group {
  width: 365px;
  // @include cardNoPadding;
}

@media (max-width: 768px) {
  .explore-page__group {
    flex-grow: 1;
  }
}

.explore-page__group-cover {
  height: 100px;
  background-size: cover;
}

.explore-page__group-details {
  // @include cardPadding;
}

.explore-page__group-description {
  margin-bottom: 20px;
}

.explore-page__show-more {
  // @include cardMinorAction;
  // @include lmoBtnLink;
}

.explore-page__group {
  // color: $primary-text-color;
}

.explore-page__group:hover {
  text-decoration: none;
  // color: $primary-text-color;
}
</style>

<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import EventBus  from '@/shared/services/event_bus'
import UrlFor    from '@/mixins/url_for'
import _truncate from 'lodash/truncate'
import _map      from 'lodash/map'
import _sortBy   from 'lodash/sortBy'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  mixins: [UrlFor]
  data: ->
    groupIds: []
    resultsCount: 0
    perPage: AppConfig.pageSize.exploreGroups
    canLoadMoreGroups: true
    query: ""
    searchExecuting: false
  mounted: ->
    EventBus.$emit 'currentComponent', { titleKey: 'explore_page.header', page: 'explorePage'}
    # applyLoadingFunction(@, 'search')
    # @search()

  methods:
    groups: ->
      Records.groups.find(@groupIds)

    handleSearchResults: (response) ->
      Records.groups.getExploreResultsCount(@query).then (data) =>
        @resultsCount = data.count
      @groupIds = @groupIds.concat _map(response.groups, 'id')
      @canLoadMoreGroups = (response.groups || []).length == @perPage
      @searchExecuting = false
    # changing the search term
    search: ->
      @searchExecuting = true
      @groupIds = []
      Records.groups.fetchExploreGroups(@query, per: @perPage).then(@handleSearchResults)

    # clicking 'show more'
    loadMore: ->
      Records.groups.fetchExploreGroups(@query, from: @groupIds.length, per: @perPage).then(@handleSearchResults)

    groupCover: (group) ->
      { 'background-image': "url(#{group.coverUrl('small')})" }

    groupDescription: (group) ->
      _truncate group.description, {length: 100} if group.description
  computed:
    showMessage: ->
      !@searching &&
      @query &&
      @groups().length > 0

    searchResultsMessage: ->
      if @groups().length == 1
        'explore_page.single_search_result'
      else
        'explore_page.multiple_search_results'

    noResultsFound: ->
      !@searching && (@groups().length < @perPage || !@canLoadMoreGroups)

    orderedGroups: ->
      _sortBy @groups(), '-recentActivityCount'
</script>

<template lang='pug'>
.lmo-one-column-layout
  main.explore-page
    h1.lmo-h1-medium(v-t="'explore_page.header'")
    //
      <md-input-container class="explore-page__search-field">
      <input ng-model="query" ng-model-options="{debounce: 600}" ng-change="search()" placeholder="{{ \'explore_page.search_placeholder\' | translate }}" id="search-field"><i aria-hidden="true" class="mdi mdi-magnify"></i>
      <loading ng-show="searchExecuting"></loading>
      </md-input-container>
    .explore-page__search-results(v-show='showMessage', v-t='{ path: searchResultsMessage, args: { resultCount: resultsCount, searchTerm: query } }')
    .explore-page__groups
      router-link.explore-page__group(v-for='group in orderedGroups', :key='group.id', :to='urlFor(group)')
        .explore-page__group-cover(:style='groupCover(group)')
        .explore-page__group-details
          h2.lmo-h2 {{group.name}}
          .explore-page__group-description {{groupDescription(group)}}
          .explore-page__group-stats.lmo-flex.lmo-flex__start.lmo-flex__center
            i.mdi.mdi-account-multiple.lmo-margin-right
            span.lmo-margin-right {{group.membershipsCount}}
            i.mdi.mdi-comment-text-outline.lmo-margin-right
            span.lmo-margin-right {{group.discussionsCount}}
            i.mdi.mdi-thumbs-up-down.lmo-margin-right
            span.lmo-margin-right {{group.pollsCount}}
            i
            span
    .lmo-show-more(v-show='canLoadMoreGroups')
      // <button v-show="!searchExecuting" @click="loadMore()" v-t="'common.action.show_more'" class="explore-page__show-more"></button>
    loading(v-show='searchExecuting')
    .explore-page__no-results-found(v-show='noResultsFound', v-html="$t('explore_page.no_results_found')")

</template>
