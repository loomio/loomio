<script lang="coffee">
import Records            from '@/shared/services/records'
import LmoUrlService      from '@/shared/services/lmo_url_service'
import EventBus from '@/shared/services/event_bus'
import { sortBy } from 'lodash'

export default
  data: ->
    isOpen: false
    query: null
    searchResults: []
    selected: []
  created: ->
    EventBus.$on 'currentComponent', =>
      @isOpen = false
  methods:
    open: ->
      @isOpen = true
      @$nextTick ->
        document.querySelector('.navbar-search input').focus()

    search: (query) ->
      # return [] unless query && query.length > 3
      Records.searchResults.fetchByFragment(query).then =>
        @searchResults = sortBy(Records.searchResults.find(query: query), ['-rank', '-lastActivityAt'])

    goToItem: (result) ->
      @query = null
      @$router.push LmoUrlService.searchResult(result)


  watch:
    query: (q) ->
      @search q if q && q.length > 2

</script>
<template lang="pug">
.navbar-search
  v-btn(icon).navbar-search__button.lmo-flex(v-if='!isOpen' @click='open()')
    .sr-only(v-t="'navbar.search.placeholder'")
    v-icon mdi-magnify
  v-autocomplete.navbar-search__input(return-object hide-no-data v-if='isOpen' v-model='selected' @change="goToItem" :search-input.sync="query" :items='searchResults' :placeholder="$t('navbar.search.placeholder')" item-text='title' item-value='key')
    template(v-slot:selection='data')
      span asdasd {{ data.item.title }}
    //-   v-chip.chip--select-single(:selected='data.selected', close, @input='goToItem(data.item)')
    //-     span {{ data.item.title }}

  //- md-autocomplete.navbar-search__input(ng-if='isOpen', md-min-length='3', md-delay='300', md-menu-class='navbar-search__results', md-selected-item='selectedResult', md-search-text='query', md-selected-item-change='goToItem(result)', md-items='result in search(query)', placeholder="{{ \'navbar.search.placeholder\' | translate }}")
  //-   md-item-template
  //-     search_result(result='result')
  //-   md-not-found
  //-     span(translate='navbar.search.no_results')
</template>
