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
    template(v-slot:item='data')
      v-list-tile-content.search-result-item
        v-list-tile-title.search-result-title(v-html='data.item.title')
        v-list-tile-sub-title.search-result-group-name(v-if='data.item.resultGroupName')
          span {{ data.item.resultGroupName }}·
          time-ago(:timestamp='data.item.lastActivityAt')
</template>
<style lang="scss">
.search-result-item {
  height: auto;
}
</style>
