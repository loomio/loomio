<style lang="scss">
@import 'variables';
@import 'mixins';
@import 'lmo_card';
.explore-page {
  @include cardPadding;
}

.explore-page__search-field {
  position: relative;
  background-color: $background-color;
  color: $primary-text-color;
  width: 100%;
  margin: 20px 0;
  i {
    position: absolute;
    top: 4px;
    right: 4px;
    color: $grey-on-white;
  }
}

.explore-page__no-results-found, .explore-page__search-results {
  margin: 20px 0;
  text-align: left;
  color: $grey-on-white;
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
  @include cardNoPadding;
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
  @include cardPadding;
}

.explore-page__group-description {
  margin-bottom: 20px;
}

.explore-page__show-more {
  @include cardMinorAction;
  @include lmoBtnLink;
}

.explore-page__group {
  color: $primary-text-color;
}

.explore-page__group:hover {
  text-decoration: none;
  color: $primary-text-color;
}
</style>

<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import EventBus  from '@/shared/services/event_bus'
import urlFor    from '@/mixins/url_for'
import _truncate from 'lodash/truncate'
import _map      from 'lodash/map'
import _sortBy   from 'lodash/sortBy'
import Session        from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  mixins: [urlFor, AuthModalMixin]
  data: ->
    groupIds: []
    resultsCount: 0
    perPage: AppConfig.pageSize.exploreGroups
    canLoadMoreGroups: true
    query: ""
  created: ->
    EventBus.$emit 'currentComponent', { titleKey: 'explore_page.header', page: 'explorePage'}
    # applyLoadingFunction(@, 'search')
    # @search()
  mounted: ->
    if !Session.isSignedIn()
      @openAuthModal()
  methods:
    groups: ->
      Records.groups.find(@groupIds)

    handleSearchResults: (response) ->
      Records.groups.getExploreResultsCount(@query).then (data) =>
        @resultsCount = data.count
      @groupIds = @groupIds.concat _map(response.groups, 'id')
      @canLoadMoreGroups = (response.groups || []).length == @perPage

    # changing the search term
    search: ->
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

<template>
  <div class="lmo-one-column-layout">
    <main class="explore-page">
      <h1 v-t="'explore_page.header'" class="lmo-h1-medium"></h1>
      <!-- <md-input-container class="explore-page__search-field">
          <input ng-model="query" ng-model-options="{debounce: 600}" ng-change="search()" placeholder="{{ \'explore_page.search_placeholder\' | translate }}" id="search-field"><i aria-hidden="true" class="mdi mdi-magnify"></i>
          <loading ng-show="searchExecuting"></loading>
      </md-input-container> -->
      <div v-show="showMessage" v-t="{ path: searchResultsMessage, args: { resultCount: resultsCount, searchTerm: query } }" class="explore-page__search-results"></div>
      <div class="explore-page__groups">
        <router-link v-for="group in orderedGroups" :key="group.id" :to="urlFor(group)" class="explore-page__group">
          <div :style="groupCover(group)" class="explore-page__group-cover"></div>
          <div class="explore-page__group-details">
            <h2 class="lmo-h2">{{group.name}}</h2>
            <div class="explore-page__group-description">{{groupDescription(group)}}</div>
            <div class="explore-page__group-stats lmo-flex lmo-flex__start lmo-flex__center">
              <i class="mdi mdi-account-multiple lmo-margin-right"></i>
              <span class="lmo-margin-right">{{group.membershipsCount}}</span>
              <i class="mdi mdi-comment-text-outline lmo-margin-right"></i>
              <span class="lmo-margin-right">{{group.discussionsCount}}</span>
              <i class="mdi mdi-thumbs-up-down lmo-margin-right"></i>
              <span class="lmo-margin-right">{{group.pollsCount}}</span>
              <i></i>
              <span></span>
            </div>
          </div>
        </router-link>
      </div>
      <div v-show="canLoadMoreGroups" class="lmo-show-more">
        <!-- <button v-show="!searchExecuting" @click="loadMore()" v-t="'common.action.show_more'" class="explore-page__show-more"></button> -->
      </div>
      <!-- <loading v-show="searchExecuting"></loading> -->
      <div v-show="noResultsFound" v-html="$t('explore_page.no_results_found')" class="explore-page__no-results-found"></div>
    </main>
  </div>
</template>
