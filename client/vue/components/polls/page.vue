<style lang="scss">
.polls-page {
  margin-top: 16px;
}

.polls-page__heading a {
  // color: $primary-text-color;
}

.polls-page__filters {
  align-items: center;
}

.polls-page__status-filter {
  margin-left: 30px;
  margin-right: 30px;
}

.polls-page__group-filter {
  min-width: 200px;
}

.polls-page__icon {
  vertical-align: middle;
  margin-bottom: 4px;
}

.polls-page__count {
  font-weight: bold;
  margin-top: 16px;
}

.polls-page__load-more {
  margin-bottom: 16px;
}

.polls-page__search {
  flex-grow: 1;
  margin: 16px 0 -10px;
  i {
    position: absolute;
    right: 0;
    // color: $grey-on-white;
  }
}

// @media (max-width: $small-max-px) {
//   .polls-page__filters { flex-direction: column; }
//   .polls-page__search { width: 100%; }
//   .polls-page__status-filter,
//   .polls-page__group-filter {
//     width: 100%;
//   }
// }
</style>
<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
RecordLoader   = require 'shared/services/record_loader'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
urlFor = require 'vue/mixins/url_for'

{ applyLoadingFunction } = require 'shared/helpers/apply'
import Loading from 'vue/components/common/loading.vue'
import PollCommonPreview from 'vue/components/poll/common/preview.vue'

module.exports =
  components:
    Loading: Loading
    PollCommonPreview: PollCommonPreview
  mixins: [urlFor]
  data: ->
    group: {}
    now: moment()
    pollIds: []
    loader: new RecordLoader
      collection: 'polls'
      path: 'search'
      params: LmoUrlService.params()
      per: 25
    fragment: null
    pollsCount: null
  created: ->
    # EventBus.broadcast $rootScope, 'currentComponent', { titleKey: 'polls_page.heading', page: 'pollsPage'}
    # applyLoadingFunction @, 'loadMore'
    # applyLoadingFunction @, 'fetchRecords'
    # @fetchRecords()
    # applyLoadingFunction(@, 'searchPolls')
  computed:
    statusFilters: -> _.map AppConfig.searchFilters.status, (filter) =>
      { name: _.capitalize(filter), value: filter }

    groupFilters: -> _.map Session.user().groups(), (group) =>
      { name: group.fullName, value: group.key }

    loadedCount: ->
      @pollCollection().polls().length

    canLoadMore: ->
      !@fragment && @loadedCount < @pollsCount

    fetching: ->
      # @fetchRecordsExecuting || @loadMoreExecuting

    orderedPolls: ->
      _.sortBy(@pollCollection().polls(), 'pollImportance')

    hasGroup: ->
      !_.isEmpty(@group)

  methods:
    statusFilter: -> LmoUrlService.params().status
    groupFilter: -> LmoUrlService.params().group_key
    pollImportance: (poll) -> poll.importance(@now)
    loadMore: ->
      @loader.loadMore().then (response) =>
        @pollIds = @pollIds.concat _.map(response.polls, 'id')
    fetchRecords: ->
      LmoUrlService.params 'group_key', @groupFilter
      LmoUrlService.params 'status',    @statusFilter
      @pollIds = []

      Records.polls.searchResultsCount(LmoUrlService.params()).then (response) =>
        @pollsCount = response.count

      @loader.fetchRecords().then (response) =>
        @group   = Records.groups.find(LmoUrlService.params().group_key)
        @pollIds = _.map(response.polls, 'id')
      , (error) ->
        # EventBus.broadcast $rootScope, 'pageError', error
    startNewPoll: ->
      ModalService.open 'PollCommonStartModal', poll: -> Records.polls.build(authorId: Session.user().id)

    searchPolls: =>
      if @fragment
        Records.polls.search(query: @fragment, per: 10)
      else
        Promise.resolve(true)

    pollCollection: ->
      polls: =>
        _.sortBy(
          _.filter(Records.polls.find(@pollIds), (poll) =>
            _.isEmpty(@fragment) or poll.title.match(///#{@fragment}///i)), '-createdAt')

</script>
<template>
  <div class="loading-wrapper lmo-one-column-layout">
    <main class="polls-page">
        <div class="lmo-flex lmo-flex__space-between lmo-flex__baseline">
            <h1 v-if="hasGroup" class="lmo-h1 dashboard-page__heading polls-page__heading">
              <a :href="urlFor(group)">
                <span v-t="{ path: 'polls_page.heading_with_group', args: { name: group.fullName }}"></span>
              </a>
            </h1>
            <h1 v-if="!hasGroup" v-t="'polls_page.heading'" class="lmo-h1 dashboard-page__heading polls-page__heading"></h1></div>
        <div class="lmo-card">
            <!-- <div class="polls-page__filters lmo-flex">
                <md-input-container md-no-float="true" class="polls-page__search md-block"><i class="mdi mdi-magnify mdi-18px"></i>
                    <input ng-model="fragment" placeholder="{{\'polls_page.search_placeholder\' | translate}}" ng-change="searchPolls()" ng-model-options="{debounce: 250}">
                </md-input-container>
                <md-select ng-model="statusFilter" placeholder="{{ \'polls_page.filter_placeholder\' | translate }}" ng-change="fetchRecords()" class="polls-page__status-filter">
                    <md-option ng-value="null">{{ 'polls_page.filter_placeholder' | translate }}</md-option>
                    <md-option ng-repeat="filter in statusFilters track by filter.value" ng-value="filter.value">{{filter.name}}</md-option>
                </md-select>
                <md-select ng-model="groupFilter" placeholder="{{ \'polls_page.groups_placeholder\' | translate }}" ng-change="fetchRecords()" class="polls-page__group-filter">
                    <md-option ng-value="null">{{ 'polls_page.groups_placeholder' | translate }}</md-option>
                    <md-option ng-repeat="filter in groupFilters track by filter.value" ng-value="filter.value">{{filter.name}}</md-option>
                </md-select>
            </div> -->
            <loading v-if="fetchRecordsExecuting"></loading>
            <div v-if="!fetchRecordsExecuting" class="polls-page__polls">
                <poll-common-preview v-for="poll in orderedPolls" :key="poll.id" :poll="poll" :display-group-name="!group"></poll-common-preview>
                <loading v-if="loadMoreExecuting"></loading>
                <div v-t="{ path: 'polls_page.polls_count', args: { count: loadedCount, total: pollsCount }}" class="polls-page__count"></div>
                <div v-if="canLoadMore" class="polls-page__load-more">
                    <button md-button v-t="'poll_common.load_more'" @click="loadMore()" class="md-primary"></button>
                </div>
            </div>
        </div>
    </main>
</div>
</template>
