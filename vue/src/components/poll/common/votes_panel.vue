<script lang="coffee">
import RecordLoader from '@/shared/services/record_loader'
import EventBus     from '@/shared/services/event_bus'
import { fieldFromTemplate } from '@/shared/helpers/poll'

sortFn =
  newest_first: (stance) ->
    -(stance.createdAt)
  oldest_first: (stance) ->
    stance.createdAt
  priority_first: (stance) ->
    stance.pollOption().priority
  priority_last: (stance) ->
    -(stance.pollOption().priority)

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')
  props:
    poll: Object
  data: ->
    fix: {}
    loader: null
  created: ->
    @fix.votesOrder = @sortOptions[0]
    @loader =  new RecordLoader
      collection: 'stances'
      params:
        poll_id: @poll.key
        order: @fix.votesOrder
    @loader.fetchRecords()
    EventBus.$on 'refreshStance', => @loader.fetchRecords()
  methods:
    hasSomeVotes: ->
      @poll.stancesCount > 0

    moreToLoad: ->
      @loader.numLoaded < @poll.stancesCount

    stances: ->
      @poll.latestStances(sortFn[@fix.votesOrder], @loader.numLoaded)

    changeOrder: ->
      @loader.reset()
      @loader.params.order = @fix.votesOrder
      @loader.fetchRecords()

  computed:
    sortOptions: ->
      fieldFromTemplate(@poll.pollType, 'sort_options').map (option) =>
        {text: @$t('poll_common_votes_panel.'+option), value: option}

</script>

<template lang="pug">
.poll-common-votes-panel
  v-layout.poll-common-votes-panel__header(wrap)
    v-subheader(v-t="'poll_common.votes'")
    v-spacer
    v-select(style="max-width: 200px" small solo v-model='fix.votesOrder' :items="sortOptions" @change='changeOrder()', aria-label="$t('poll_common_votes_panel.change_results_order')")
  .poll-common-votes-panel__no-votes(v-if='!hasSomeVotes()', v-t="'poll_common_votes_panel.no_votes_yet'")
  .poll-common-votes-panel__has-votes(v-if='hasSomeVotes()')
    v-list
      poll-common-directive(:stance='stance', name='votes-panel-stance', v-for='stance in stances()', :key='stance.id')
    button(v-if='moreToLoad()', v-t="'common.action.load_more'", @click='loader.loadMore()')
  poll-common-undecided-panel(:poll='poll')
</template>
