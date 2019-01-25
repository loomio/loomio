<script lang="coffee">
Records       = require 'shared/services/records'
LmoUrlService = require 'shared/services/lmo_url_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

module.exports =
  props:
    model: Object
    limit: Number
    viewMoreLink: Boolean
  created: ->
    applyLoadingFunction(@, 'fetchRecords')
    @fetchRecords()
  methods:
    fetchRecords: ->
      Records.polls.fetchFor(@model, limit: @limit, status: 'closed')

    displayViewMore: ->
      @viewMoreLink and
      @model.closedPollsCount > @polls().length

    viewMore: ->
      LmoUrlService.goTo('polls')
      LmoUrlService.params("#{@model.constructor.singular}_key", @model.key)
      LmoUrlService.params('status', 'closed')

    polls: ->
      _.take @model.closedPolls(), (@limit or 50)

</script>

<template>
  <v-card class="poll-common-index-card mb-2">
    <v-card-text>
      <h2 v-t="'poll_common_index_card.title'" class="lmo-card-heading"></h2>
      <div class="poll-common-index-card__polls">
        <div v-if="!polls().length" v-t="'poll_common_index_card.no_polls'" class="lmo-hint-text"></div>
        <div v-if="polls().length" class="poll-common-index-card__has-polls">
          <poll-common-preview v-for="poll in polls()" :key="poll.id" :poll="poll"></poll-common-preview>
          <a @click="viewMore()" v-if="displayViewMore()" class="poll-common-index-card__view-more">
            <span v-t="{ path: 'poll_common_index_card.count', args: { count: model.closedPollsCount } }"></span>
          </a>
        </div>
      </div>
      <!-- <loading v-if="fetchRecordsExecuting"></loading> -->
    </v-card-text>
  </v-card>
</template>

<style lang="scss">
.poll-common-index-card__view-more {
  cursor: pointer;
}
</style>
