<script lang="coffee">
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
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

<template lang="pug">
v-card.poll-common-index-card
  v-subheader(v-t="'poll_common_index_card.title'")
  v-card-text(v-if='!polls().length')
    .lmo-hint-text(v-t="'poll_common_index_card.no_polls'")
  v-list.poll-common-index-card__polls(two-line v-if='polls().length')
    poll-common-preview(v-for='poll in polls()', :key='poll.id', :poll='poll')
  v-card-actions
    v-btn.poll-common-index-card__view-more(flat, @click='viewMore()', v-if='displayViewMore()')
      span(v-t="{ path: 'poll_common_index_card.count', args: { count: model.closedPollsCount } }")
    // <loading v-if="fetchRecordsExecuting"></loading>
</template>
