<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import EventBus  from '@/shared/services/event_bus'
import UrlFor    from '@/mixins/url_for'
import _truncate from 'lodash/truncate'
import _map      from 'lodash/map'
import _sortBy   from 'lodash/sortBy'
import marked    from 'marked'

import { debounce } from 'lodash'

export default
  mixins: [UrlFor]
  data: ->
    groupIds: []
    resultsCount: 0
    perPage: 50
    canLoadMoreGroups: true
    query: ""
    searching: false
  mounted: ->
    EventBus.$emit 'currentComponent', { titleKey: 'explore_page.header', page: 'explorePage'}
    @search()

  methods:
    groups: ->
      Records.groups.find(@groupIds)

    handleSearchResults: (response) ->
      Records.groups.getExploreResultsCount(@query).then (data) =>
        @resultsCount = data.count
      @groupIds = @groupIds.concat _map(response.groups, 'id')
      @canLoadMoreGroups = (response.groups || []).length == @perPage
      @searching = false

    search: debounce ->
      @groupIds = []
      Records.groups.fetchExploreGroups(@query, per: @perPage).then(@handleSearchResults)
    , 250

    loadMore: ->
      Records.groups.fetchExploreGroups(@query, from: @groupIds.length, per: @perPage).then(@handleSearchResults)

    groupCover: (group) ->
      { 'background-image': "url(#{group.coverUrl('small')})" }

    groupDescription: (group) ->
      description = group.description || ''
      if group.descriptionFormat == 'md'
        description = marked(description)
      parser = new DOMParser()
      doc = parser.parseFromString(description, 'text/html')
      _truncate doc.body.textContent, {length: 100}
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
      !@searching && (@groups().length < @perPage)

    orderedGroups: ->
      _sortBy @groups(), '-recentActivityCount'

  watch:
    'query': ->
      @searching = true
      @search()
</script>

<template lang='pug'>
v-content
  v-container.explore-page.max-width-1024
    //- h1.headline(v-t="'explore_page.header'")
    v-text-field(v-model="query" :placeholder="$t('explore_page.search_placeholder')" id="search-field" append-icon="mdi-magnify")

    loading(v-show="searching")

    .explore-page__search-results(v-show='showMessage', v-html="$t(searchResultsMessage, {resultCount: resultsCount, searchTerm: query})")
    v-row.explore-page__groups.my-4(wrap)
      v-col(:lg="6" :md="6" :sm="12" v-for='group in orderedGroups', :key='group.id')
        v-card.explore-page__group.my-4(:to='urlFor(group)')
          v-img.explore-page__group-cover(:src="group.coverUrl('small')")
          v-card-title {{ group.name }}
          v-card-text
            .explore-page__group-description {{groupDescription(group)}}
            v-layout.explore-page__group-stats(justify-start align-center)
              v-icon.mr-2 mdi-account-multiple
              span.mr-4 {{group.membershipsCount}}
              v-icon.mr-2 mdi-comment-text-outline
              span.mr-4 {{group.discussionsCount}}
              v-icon.mr-2 mdi-thumbs-up-down
              span.mr-4 {{group.pollsCount}}
    .lmo-show-more(v-show='canLoadMoreGroups')
      v-btn(v-show="!searching" @click="loadMore()" v-t="'common.action.show_more'" class="explore-page__show-more")
    .explore-page__no-results-found(v-show='noResultsFound', v-html="$t('explore_page.no_results_found')")

</template>
