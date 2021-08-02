<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'

import {sum, map, sortBy, find, compact, uniq} from 'lodash'

export default
  props:
    poll: Object
    zone: Object
  data: ->
    pollOptions: []

  created: ->
    @watchRecords
      collections: ['poll_options']
      query: (store) =>
        @pollOptions = @poll.pollOptions()
        @decidedVoters = @poll.decidedVoters()

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

    barLength: (count) ->
      ((count * 32)) + 'px'

    classForScore: (score) ->
      switch score
        when 2 then 'poll-meeting-chart__cell--yes'
        when 1 then 'poll-meeting-chart__cell--maybe'
        else
          'poll-meeting-chart__cell--no'

  computed:
    currentUserTimeZone: ->
      Session.user().timeZone
</script>

<template lang="pug">
.poll-meeting-chart-panel
  table.poll-meeting-chart-table.body-2
    thead
      tr
        td.text--secondary {{currentUserTimeZone}}
        td(v-for="user in decidedVoters" :key="user.id")
          user-avatar(:user="user")
        td.total(v-t="'common.total'")
    tbody
      tr(v-for="option in pollOptions" :key="option.id")
        td.poll-meeting-chart__meeting-time
          poll-meeting-time(:name='option.name' :zone='zone')

        td(v-for="user in decidedVoters" :key="user.id")
          .poll-meeting-chart__cell(:class="classForScore(option.voterScores[user.id])")
            | &nbsp;
        td.total
          strong {{option.totalScore/2}}
</template>

<style lang="sass">
.poll-meeting-chart-panel
  overflow-x: scroll

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
  font-family: 'Roboto Mono'
  font-size: 12px
  padding-right: 24px

.total
  padding-left: 24px
</style>
