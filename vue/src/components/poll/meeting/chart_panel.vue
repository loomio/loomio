<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'

import {sum, map, sortBy, find, compact, uniq} from 'lodash-es'

export default
  mixins: [WatchRecords]
  props:
    poll: Object
    zone: Object
  data: ->
    pollOptions: []
    latestStances: []
    participants: []
    stancesByUserId: []

  created: ->
    @watchRecords
      collections: ['stances', 'poll_options']
      query: (store) =>
        @latestStances = @poll.latestStances()

        @stancesByUserId = {}
        @latestStances.forEach (stance) =>
          @stancesByUserId[stance.participantId] = stance

        @pollOptions = @poll.pollOptions()
        @participants = @poll.participants()

  methods:
    scoreColor: (score) ->
      switch score
        when 2 then AppConfig.pollColors.proposal[0]
        when 1 then AppConfig.pollColors.proposal[1]
        when 0 then AppConfig.pollColors.proposal[2]

    bgColor: (score) ->
      switch score
        when 2 then "rgba(0, 209, 119, 0.5)"
        when 1 then "rgba(246, 168, 43, 0.5)"

    yesVotersFor: (option) ->
      uniq @choicesFor(option, 2).map (choice) -> choice.stance().participant()

    maybeVotersFor: (option) ->
      uniq @choicesFor(option, 1).map (choice) -> choice.stance().participant()

    choicesFor: (option, score) ->
      compact @latestStances.map (stance) ->
        find stance.stanceChoices(), (choice) ->
          choice.pollOption() == option && choice.score == score

    totalFor: (option) ->
      sum map(option.stanceChoices().filter((choice) -> choice.stance().latest), 'score')

    barLength: (count) ->
      ((count * 32)) + 'px'

    scoreFor: (user, option) ->
      if @stancesByUserId[user.id]
        @stancesByUserId[user.id].scoreFor(option)
      else
        0

    classForScore: (score) ->
      switch score
        when 2 then 'poll-meeting-chart__cell--yes'
        when 1 then 'poll-meeting-chart__cell--maybe'
        when 0 then 'poll-meeting-chart__cell--no'

  computed:
    currentUserTimeZone: ->
      Session.user().timeZone
</script>

<template lang="pug">
.poll-meeting-chart-panel
  table.poll-meeting-chart-table.body-2
    thead
      tr
        td {{currentUserTimeZone}}
        td(v-for="user in participants" :key="user.id")
          user-avatar(:user="user")
        td.total(v-t="'common.total'")
    tbody
      tr(v-for="option in pollOptions" :key="option.id")
        td.poll-meeting-chart__meeting-time
          poll-meeting-time(:name='option.name' :zone='zone')

        td(v-for="user in participants" :key="user.id")
          .poll-meeting-chart__cell(:class="classForScore(scoreFor(user, option))")
            | &nbsp;
            //- v-layout
            //-   span.poll-meeting-chart__bar(v-if="option.scoreCounts['2']" :style="{'border-color': scoreColor(2), 'background-color': bgColor(2), 'width': barLength(option.scoreCounts['2']) }")
            //-     user-avatar(size="24" :user="user" v-for="user in yesVotersFor(option)" :key="user.id")
            //-   span.poll-meeting-chart__bar(v-if="option.scoreCounts['1']" :style="{'border-color': scoreColor(1), 'background-color': bgColor(1), 'width': barLength(option.scoreCounts['1']) }")
            //-     user-avatar(size="24" :user="user" v-for="user in maybeVotersFor(option)" :key="user.id")
        td.total
          strong {{totalFor(option)/2}}
</template>

<style lang="sass">
.poll-meeting-chart-panel
  overflow-x: scroll

.poll-meeting-chart-panel:hover
  overflow-x: visible

.poll-meeting-chart-table
  width: auto
  background-color: none

.poll-meeting-chart-table tbody tr:hover
  background-color: #EEEEEE

.poll-meeting-chart__bar
  border: 1px solid
  margin: 4px 0px
  /* padding: 0 2px */
  display: flex
  flex-direction: row
  align-items: center
  justify-content: space-around
  height: 36px
  border-radius: 2px

.poll-meeting-chart__cell
  padding: 0
  width: 36px
.poll-meeting-chart__cell--yes
  background-color: #00D177

.poll-meeting-chart__cell--maybe
  background-color: #F6A82B

.poll-meeting-chart__meeting-time
  padding-right: 24px

.total
  padding-left: 24px
</style>
