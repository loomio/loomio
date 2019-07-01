<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'
import AppConfig from '@/shared/services/app_config'

import {reduce, sortBy, find, compact, uniq} from 'lodash'

export default
  mixins: [WatchRecords]
  props:
    poll: Object
    zone: Object
  data: ->
    pollOptions: []
    latestStances: []
  created: ->
    @watchRecords
      collections: ['stances', 'poll_options']
      query: (store) =>
        @latestStances = @poll.latestStances()
        @pollOptions = @poll.pollOptions()
    # EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
    #   $scope.zone = zone

  methods:
    scoreColor: (score) ->
      switch score
        when 2 then AppConfig.pollColors.proposal[0]
        when 1 then AppConfig.pollColors.proposal[1]
        when 0 then AppConfig.pollColors.proposal[2]

    yesVotersFor: (option) ->
      uniq @choicesFor(option, 2).map (choice) -> choice.stance().participant()

    maybeVotersFor: (option) ->
      uniq @choicesFor(option, 1).map (choice) -> choice.stance().participant()

    choicesFor: (option, score) ->
      compact @latestStances.map (stance) ->
        find stance.stanceChoices(), (choice) ->
          choice.pollOption() == option && choice.score == score

    totalFor: (option) ->
      _reduce(@latestStances, (total, stance) =>
        scoreForStance = stance.scoreFor(option)
        total[scoreForStance] += 1
        total
      , [0, 0, 0])

  computed:
    orderedPollOptions: ->
      sortBy @pollOptions, 'name'
</script>

<template lang="pug">
.poll-meeting-chart-panel
  table
    tr
      td
        //- time-zone-select
      td
        //-
    tr(v-for="option in orderedPollOptions" :key="option.id")
      td
        poll-meeting-time(:name='option.name' :zone='zone')
      td
        span.poll-meeting-chart__bar(v-if="yesVotersFor(option).length" :style="{'border-color': scoreColor(2)}")
          user-avatar(size="24" :user="user" v-for="user in yesVotersFor(option)" :key="user.id")
        span.poll-meeting-chart__bar(v-if="maybeVotersFor(option).length" :style="{'border-color': scoreColor(1)}")
          user-avatar(size="24" :user="user" v-for="user in maybeVotersFor(option)" :key="user.id")


</template>
<style lang="scss">
.poll-meeting-chart__bar {
  padding: 3px;
  display: flex;
  align-items: center;
  border: 1px solid;
  border-radius: 20px
}
</style>
