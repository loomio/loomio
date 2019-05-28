<script lang="coffee">
import Records            from '@/shared/services/records'
import LmoUrlService      from '@/shared/services/lmo_url_service'
import EventBus from '@/shared/services/event_bus'
import { sortBy } from 'lodash'

export default
  data: ->
    isOpen: false
    query: ''
    searchResults: []
    selected: []
  created: ->
    EventBus.$on 'currentComponent', =>
      @isOpen = false
  methods:
    open: ->
      @isOpen = true
      # @$nextTick ->
      #   document.querySelector('.navbar-search input').focus()

    search: (query) ->
      # return [] unless query && query.length > 3
      Records.searchResults.fetchByFragment(query).then =>
        @searchResults = sortBy(Records.searchResults.find(query: query), ['-rank', '-lastActivityAt'])
        console.log '@searchResults', @searchResults

    goToItem: (result) ->
      return unless result
      LmoUrlService.goTo LmoUrlService.searchResult(result)
      $scope.query = ''

  watch:
    query: (q) ->
      console.log 'searching q', q
      @search q if q && q.length > 2

</script>
<template lang="pug">
.navbar-search
  v-btn(icon).navbar-search__button.lmo-flex(v-if='!isOpen' @click='open()')
    .sr-only(v-t="'navbar.search.placeholder'")
    v-icon mdi-magnify

  v-autocomplete.navbar-search__input(return-object chips hide-no-data v-if='isOpen' v-model='selected' @change="query= ''" :search-input.sync="query" :items='searchResults' :placeholder="$t('navbar.search.placeholder')")
    template(v-slot:selection='data')
      v-chip.chip--select-single(:selected='data.selected', close, @input='remove(data.item)')
        span {{ data.item.title }}
    //- v-autocomplete.announcement-form__input(multiple chips return-object autofocus v-model='recipients' @change="query= ''" :search-input.sync="query" item-text='name' item-value="id" item-avatar="avatar_url.large" :placeholder="$t('announcement.form.placeholder')" :items='searchResults')
    //-   template(v-slot:selection='data')
    //-     v-chip.chip--select-multi(:selected='data.selected', close, @input='remove(data.item)')
    //-       user-avatar(:user="data.item" size="small" :no-link="true")
    //-       span {{ data.item.name }}

  //- md-autocomplete.navbar-search__input(ng-if='isOpen', md-min-length='3', md-delay='300', md-menu-class='navbar-search__results', md-selected-item='selectedResult', md-search-text='query', md-selected-item-change='goToItem(result)', md-items='result in search(query)', placeholder="{{ \'navbar.search.placeholder\' | translate }}")
  //-   md-item-template
  //-     search_result(result='result')
  //-   md-not-found
  //-     span(translate='navbar.search.no_results')
</template>

<style lang="scss">
</style>
<!--
Records       = require 'shared/services/records'
EventBus      = require 'shared/services/event_bus'
LmoUrlService = require 'shared/services/lmo_url_service'

angular.module('loomioApp').directive 'navbarSearch', ['$timeout', ($timeout) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_search.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.isOpen = false

    EventBus.listen $scope, 'currentComponent', ->
      $scope.isOpen = false

    $scope.open = ->
      $scope.isOpen = true
      $timeout ->
        document.querySelector('.navbar-search input').focus()

    $scope.query = ''

    $scope.search = (query) ->
      return [] unless query && query.length > 3
      Records.searchResults.fetchByFragment(query).then ->
        _.sortBy(Records.searchResults.find(query: query), ['-rank', '-lastActivityAt'])


    $scope.goToItem = (result) ->
      return unless result
      LmoUrlService.goTo LmoUrlService.searchResult(result)
      $scope.query = ''
  ]
] -->
