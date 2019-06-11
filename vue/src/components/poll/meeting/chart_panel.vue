<style lang="scss">
.poll-meeting-chart-panel {
  overflow-x: scroll;
}

.poll-meeting-chart-panel__cell {
  padding: 0 5px;
  text-align: center;
}

.poll-meeting-chart-panel .lmo-h3 {
  margin-bottom: 0;
}

.poll-meeting-chart-panel__cell--no-padding {
  padding: 0;
}

.poll-meeting-chart-panel__participant-name {
  padding-right: 16px;
}

.poll-meeting-chart-panel__total-icon {
  margin: 0 8px 0 4px;
}

.poll-meeting-chart-panel__bold {
  font-weight: bold;
}
</style>

<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import _reduce from 'lodash/reduce'
import _sortBy from 'lodash/sortBy'

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
    totalFor: (option) ->
      _reduce(@latestStances, (total, stance) =>
        scoreForStance = stance.scoreFor(option)
        total[scoreForStance] += 1
        total
      , [0, 0, 0])

  computed:
    orderedPollOptions: ->
      _sortBy @pollOptions, 'name'
</script>

<template lang="pug">
.poll-meeting-chart-panel
  table
    thead
      tr
        td
          time-zone-select
        td.poll-meeting-chart-panel__cell(v-for="option in orderedPollOptions", :key="option.id")
          poll-meeting-time(:name='option.name', :zone='zone')
    tbody
      tr.poll-meeting-chart-panel__bold
        td
          v-subheader(v-t="'poll_common.totals'")
      tr
        td.poll-meeting-chart-panel__cell
          poll-meeting-stance-icon(:score='2')
          span(v-t="'poll_meeting_vote_form.can_attend'")
        td.poll-meeting-chart-panel__cell.poll-meeting-chart-panel--active(v-for="option in orderedPollOptions", :key="option.id") {{ totalFor(option)[2]}}
      tr(v-if='poll.canRespondMaybe')
        td.poll-meeting-chart-panel__cell
          poll-meeting-stance-icon(:score='1')
          span(v-t="'poll_meeting_vote_form.if_need_be'")
        td.poll-meeting-chart-panel__cell.poll-meeting-chart-panel--maybe(v-for="option in orderedPollOptions", :key="option.id") {{ totalFor(option)[1]}}
      tr.poll-meeting-chart-panel__bold
        td
          v-subheader(v-t="'poll_common.responses'")
      tr(v-for="stance in poll.latestStances()", :key="stance.id")
        td.poll-meeting-chart-panel__participant-name
          user-avatar(size='small', :user='stance.participant()')
          div {{ stance.participant().name }}
        td.poll-meeting-chart-panel__cell(v-for="option in orderedPollOptions", :key="option.id", :class="{'poll-meeting-chart-panel--yes': stance.scoreFor(option)==2, 'poll-meeting-chart-panel--no': stance.scoreFor(option)==0,  'poll-meeting-chart-panel--maybe': stance.scoreFor(option)==1}")
          poll-meeting-stance-icon(:score='stance.scoreFor(option)')
</template>
