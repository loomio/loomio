<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import PollCommonDirective from '@/components/poll/common/directive'
import PollService from '@/shared/services/poll_service'
import { pick } from 'lodash'

# import PollCommonChartCount from '@/components/poll/common/chart/count'
import PollCommonChartMeeting from '@/components/poll/common/chart/meeting'
import PollCommonChartTable from '@/components/poll/common/chart/table'

export default
  components:
    {PollCommonChartTable,
     PollCommonChartMeeting}

  props:
    poll: Object

  data: ->
    votersByOptionId: {}

  created: ->
    @watchRecords
      collections: ['polls']
      query: =>
        if Session.isSignedIn()
          Records.users.fetchAnyMissingById(@poll.decidedVoterIds())

</script>

<template lang="pug">
.poll-common-chart-panel
  template(v-if="!poll.showResults")
    v-alert.poll-common-action-panel__results-hidden-until-closed.my-2(dense outlined type="info" v-if='poll.hideResults == "until_closed"')
      span( v-t="{path: 'poll_common_action_panel.results_hidden_until_closed', args: {poll_type: poll.pollType}}" )
    v-alert.poll-common-action-panel__results-hidden-until-vote.my-2(dense outlined type="info" v-if='!poll.iHaveVoted() && poll.hideResults == "until_vote"')
      span( v-t="'poll_common_action_panel.results_hidden_until_vote'")
  template(v-else)
    v-subheader.ml-n4
      span(v-t="poll.closedAt ? 'poll_common.results' : 'poll_common.current_results'")
    poll-common-chart-table(v-if="poll.chartType != 'grid'" :poll="poll")
    poll-common-chart-meeting(v-else :poll="poll")
  poll-common-percent-voted(:poll="poll")
</template>

<style lang="sass">
</style>
