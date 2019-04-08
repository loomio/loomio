<style lang="scss">
@import 'variables';
.poll-common-votes-panel__no-votes {
  color: $grey-on-white;
  font-style: italic;
}

.poll-common-votes-panel__header {
  display: flex;
  justify-content: space-between;
}

.poll-common-votes-panel__header md-select {
  margin-bottom: 0;
}

.poll-common-votes-panel__did-not-voter {
  display: flex;
  align-items: center;
  margin: 8px 0;
}

.poll-common-votes-panel__stance-name-and-option .poll-common-stance-choice {
  display: inline-block;
}
</style>

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
  props:
    poll: Object
  data: ->
    fix: {}
    sortOptions: fieldFromTemplate(@poll.pollType, 'sort_options')
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
</script>

<template>
    <div class="poll-common-votes-panel">
      <div class="poll-common-votes-panel__header">
        <h3 v-t="'poll_common.votes'" class="lmo-card-subheading"></h3>
        <select v-model="fix.votesOrder" @change="changeOrder()" aria-label="$t('poll_common_votes_panel.change_results_order')" class="md-no-underline">
          <option v-for="opt in sortOptions" :value="opt" v-t="'poll_common_votes_panel.' + opt"></option>
        </select>
      </div>
      <div v-if="!hasSomeVotes()" v-t="'poll_common_votes_panel.no_votes_yet'" class="poll-common-votes-panel__no-votes"></div>
      <div v-if="hasSomeVotes()" class="poll-common-votes-panel__has-votes">
        <poll-common-directive :stance="stance" name="votes-panel-stance" v-for="stance in stances()" :key="stance.id"></poll-common-directive>
        <button v-if="moreToLoad()" v-t="'common.action.load_more'" @click="loader.loadMore()"></button>
      </div>
      <poll-common-undecided-panel :poll="poll"></poll-common-undecided-panel>
    </div>
</template>
